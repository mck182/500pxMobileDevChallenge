TEMPLATE = app

CONFIG += c++11 testcase

QT += qml quick testlib
android: QT += androidextras

DEFINES += \
    TEST_MODE=1

SOURCES += test.cpp \
    ../restwrapper.cpp \
    ../photosmodel.cpp \
    ../photoitem.cpp \
    ../useritem.cpp

RESOURCES += ../qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.

HEADERS += \
    ../restwrapper.h \
    ../photosmodel.h \
    ../photoitem.h \
    ../useritem.h
