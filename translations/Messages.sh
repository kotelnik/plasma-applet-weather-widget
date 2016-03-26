#!/bin/sh

$XGETTEXT `find .. -name \*.qml` -L JavaScript -o $podir/plasma_applet_org.kde.weatherWidget.pot
