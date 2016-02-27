#include <QtTest/QtTest>

#include "../photosmodel.h"
#include "../restwrapper.h"
#include "../photoitem.h"

class TestRestService: public QObject
{
    Q_OBJECT

public:
    TestRestService();

private Q_SLOTS:
    void testPhotoRequest();
    void testFetchMore();
    void testErrors();
    void testFeatureChange();
    void testPhotoItem();
    void testUserItem();

private:
    PhotosModel *m_model;
    RestWrapper *m_restWrapper;
    QJsonDocument m_jsonData;
};

TestRestService::TestRestService()
{
    m_restWrapper = new RestWrapper();
    m_model = new PhotosModel(m_restWrapper);
}

void TestRestService::testPhotoRequest()
{
    QSignalSpy activeRequestSpy(m_restWrapper, SIGNAL(requestActive(bool)));
    QSignalSpy photosRetrievedSpy(m_restWrapper, SIGNAL(photosRetrieved(QJsonDocument)));
    QSignalSpy requestErrorSpy(m_restWrapper, SIGNAL(requestError(QNetworkReply::NetworkError)));
    QSignalSpy modelInsertedSpy(m_model, SIGNAL(rowsInserted(QModelIndex,int,int)));
    QSignalSpy modelHasActiveRequestSpy(m_model, SIGNAL(activeRequestChanged(bool)));


    m_model->setFeature("popular");

    photosRetrievedSpy.wait();
    activeRequestSpy.wait(1000);

    // There must be exactly 2 requestActive() signals;
    // first one is with "true", second with "false"
    QCOMPARE(activeRequestSpy.count(), 2);

    bool firstArg = activeRequestSpy.at(0).at(0).toBool();
    bool secondArg = activeRequestSpy.at(1).at(0).toBool();

    QCOMPARE(firstArg, true);
    QCOMPARE(secondArg, false);

    // The wrapper correctly signals that the data were retrieved
    QCOMPARE(photosRetrievedSpy.count(), 1);

    m_jsonData = photosRetrievedSpy.at(0).at(0).toJsonDocument();

    // The model must have emitted 2 activeRequestChanged
    QCOMPARE(modelHasActiveRequestSpy.count(), 2);
    firstArg = modelHasActiveRequestSpy.at(0).at(0).toBool();
    secondArg = modelHasActiveRequestSpy.at(1).at(0).toBool();

    QCOMPARE(firstArg, true);
    QCOMPARE(secondArg, false);

    // At this point the model must not have any active request
    QVERIFY(!m_model->hasActiveRequest());

    modelInsertedSpy.wait(1000);

    // The model has to signal one single insert operation
    // and must have inserted 3 items
    QCOMPARE(modelInsertedSpy.count(), 1);
    QCOMPARE(modelInsertedSpy.at(0).at(2).toInt(), 3);

    // The model must have 3 rows now
    QCOMPARE(m_model->rowCount(QModelIndex()), 3);
}

void TestRestService::testFetchMore()
{
    QSignalSpy activeRequestSpy(m_restWrapper, SIGNAL(requestActive(bool)));
    QSignalSpy photosRetrievedSpy(m_restWrapper, SIGNAL(photosRetrieved(QJsonDocument)));
    QSignalSpy requestErrorSpy(m_restWrapper, SIGNAL(requestError(QNetworkReply::NetworkError)));
    QSignalSpy modelInsertedSpy(m_model, SIGNAL(rowsInserted(QModelIndex,int,int)));
    QSignalSpy modelHasActiveRequestSpy(m_model, SIGNAL(activeRequestChanged(bool)));

    // Verify that the model can fetch more data
    QVERIFY(m_model->canFetchMore());

    activeRequestSpy.clear();
    photosRetrievedSpy.clear();

    m_model->fetchMore();

    photosRetrievedSpy.wait();
    activeRequestSpy.wait(1000);

    // There must be exactly 2 requestActive() signals;
    // first one is with "true", second with "false"
    QCOMPARE(activeRequestSpy.count(), 2);
    bool firstArg = activeRequestSpy.at(0).at(0).toBool();
    bool secondArg = activeRequestSpy.at(1).at(0).toBool();

    QCOMPARE(firstArg, true);
    QCOMPARE(secondArg, false);
    QCOMPARE(photosRetrievedSpy.count(), 1);

    // Now the model must not be able to fetch anymore data
    QVERIFY(!m_model->canFetchMore());

    // The model must have 5 rows now (one photo was a duplicate)
    QCOMPARE(m_model->rowCount(QModelIndex()), 5);

    // Finally, test retryFetch, which should fetch
    // the same data again. This means that there would
    // be signals about active request but no new data
    // would be added (as they are already in the model)
    activeRequestSpy.clear();

    m_model->retryFetch();

    activeRequestSpy.wait(1000);
    QCOMPARE(activeRequestSpy.count(), 2);

    QCOMPARE(m_model->rowCount(QModelIndex()), 5);
}

void TestRestService::testFeatureChange()
{
    QSignalSpy activeRequestSpy(m_restWrapper, SIGNAL(requestActive(bool)));
    QSignalSpy photosRetrievedSpy(m_restWrapper, SIGNAL(photosRetrieved(QJsonDocument)));
    QSignalSpy modelResetSpy(m_model, SIGNAL(modelReset()));
    QSignalSpy modelFeatureChangedSpy(m_model, SIGNAL(featureChanged()));

    QCOMPARE(m_model->feature(), QString("popular"));

    m_model->setFeature("editors");

    photosRetrievedSpy.wait();
    activeRequestSpy.wait(1000);

    // There must be exactly 2 requestActive() signals;
    // first one is with "true", second with "false"
    QCOMPARE(activeRequestSpy.count(), 2);

    QCOMPARE(modelResetSpy.count(), 1);
    QCOMPARE(modelFeatureChangedSpy.count(), 1);
    QCOMPARE(m_model->feature(), QString("editors"));
}

void TestRestService::testErrors()
{
    QSignalSpy activeRequestSpy(m_restWrapper, SIGNAL(requestActive(bool)));
    QSignalSpy photosRetrievedSpy(m_restWrapper, SIGNAL(photosRetrieved(QJsonDocument)));
    QSignalSpy requestErrorSpy(m_restWrapper, SIGNAL(requestError(QNetworkReply::NetworkError)));
    QSignalSpy modelInsertedSpy(m_model, SIGNAL(rowsInserted(QModelIndex,int,int)));
    QSignalSpy modelHasActiveRequestSpy(m_model, SIGNAL(activeRequestChanged(bool)));

    QCOMPARE(m_restWrapper->lastConnectionError(), QString());
    QCOMPARE(m_model->connectionError(), QString());

    // Now test error signals by requesting invalid page
    m_restWrapper->requestPhotos(4);

    requestErrorSpy.wait(1000);

    QCOMPARE(requestErrorSpy.count(), 1);
    QVERIFY(!m_restWrapper->lastConnectionError().isEmpty());
    QVERIFY(!m_model->connectionError().isEmpty());

    // The wrapper must signal 2 activeRequest with true and false
    QCOMPARE(activeRequestSpy.count(), 2);
    bool firstArg = activeRequestSpy.at(0).at(0).toBool();
    bool secondArg = activeRequestSpy.at(1).at(0).toBool();
    QCOMPARE(firstArg, true);
    QCOMPARE(secondArg, false);

    // The wrapper must not signal a photosRetrieved
    // in case of an error
    QCOMPARE(photosRetrievedSpy.count(), 0);
}

void TestRestService::testPhotoItem()
{
    const PhotoItem photoItem(m_jsonData.object().value("photos").toArray().at(0).toObject());

    QCOMPARE(photoItem.name(), QString("First"));
    QCOMPARE(photoItem.width(), 1080);
    QCOMPARE(photoItem.height(), 2080);
    QCOMPARE(photoItem.size(), QSize(1080, 2080));
    QCOMPARE(photoItem.userId(), 288560);
    // Test default size (30)
    QCOMPARE(photoItem.imageUrl(), QString("image_test_url_small"));
    // Test valid full size
    QCOMPARE(photoItem.imageUrl(QString("1080")), QString("image_test_url_big"));
    // Test invalid size, returns the default "image_url"
    QCOMPARE(photoItem.imageUrl(QString("333")), QString("image_test_url"));
}

void TestRestService::testUserItem()
{
    const UserItem userItem(m_jsonData.object().value("photos").toArray().at(0).toObject().value("user").toObject());

    QCOMPARE(userItem.id(), 288560);
    QCOMPARE(userItem.fullname(), QString("User 1"));
    QCOMPARE(userItem.userpicUrl(), QString("userpic_test_url"));
}

QTEST_GUILESS_MAIN(TestRestService)
#include "test.moc"
