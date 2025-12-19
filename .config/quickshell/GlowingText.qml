// GlowingText.qml
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    // --- Component API ---
    // Content
    property string text: ""

    // Style
    property color sourceColor: "cyan"   // Color of the text shape used for the glow
    property color glowColor: "white"    // Color of the actual glow effect
    property color centerColor: "white"  // Color of the crisp text on top
    property int pixelSize: 14
    property string fontFamily: "JetBrainsMono Nerd Font"
    property bool bold: true
    property real glowRadius: 8
    property real glowSpread: 0.4

    // Text properties
    property alias elide: mainText.elide
    property alias maximumLineCount: mainText.maximumLineCount

    // The root item is a Layout-enabled item, so you can use
    // Layout.fillWidth, Layout.rightMargin, etc. when you
    // instantiate this component inside a Layout.
    implicitWidth: mainText.implicitWidth
    implicitHeight: mainText.implicitHeight

    // --- Implementation ---
    Text {
        id: glowSource
        text: root.text
        font.pixelSize: root.pixelSize
        font.family: root.fontFamily
        font.bold: root.bold
        color: root.sourceColor
        visible: false
    }

    Glow {
        anchors.fill: glowSource
        source: glowSource
        radius: root.glowRadius
        samples: 17 // Odd numbers can look better
        color: root.glowColor
        spread: root.glowSpread
    }

    Text {
        id: mainText
        text: root.text
        font.pixelSize: root.pixelSize
        font.family: root.fontFamily
        font.bold: root.bold
        color: root.centerColor
    }
}
