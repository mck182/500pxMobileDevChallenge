TEMPLATE = app

CONFIG += c++11

QT += qml quick

SOURCES += main.cpp \
    restwrapper.cpp \
    photosmodel.cpp \
    photoitem.cpp \
    useritem.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    restwrapper.h \
    photosmodel.h \
    photoitem.h \
    useritem.h

