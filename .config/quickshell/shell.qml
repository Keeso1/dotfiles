import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.I3
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

ShellRoot {
    id: root

    // Font
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    // System info properties
    property string kernelVersion: "Linux"
    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0
    property int volumeLevel: 0
    property int batteryLevel: 0
    property int notificationHistory: 0
    property string activeWindow: "Window"

    // CPU tracking
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    // Kernel version
    Process {
        id: kernelProc
        command: ["uname", "-r"]
        stdout: SplitParser {
            onRead: data => {
                if (data)
                    kernelVersion = data.trim();
            }
        }
        Component.onCompleted: running = true
    }

    // CPU usage
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.trim().split(/\s+/);
                var user = parseInt(parts[1]) || 0;
                var nice = parseInt(parts[2]) || 0;
                var system = parseInt(parts[3]) || 0;
                var idle = parseInt(parts[4]) || 0;
                var iowait = parseInt(parts[5]) || 0;
                var irq = parseInt(parts[6]) || 0;
                var softirq = parseInt(parts[7]) || 0;

                var total = user + nice + system + idle + iowait + irq + softirq;
                var idleTime = idle + iowait;

                if (lastCpuTotal > 0) {
                    var totalDiff = total - lastCpuTotal;
                    var idleDiff = idleTime - lastCpuIdle;
                    if (totalDiff > 0) {
                        cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff);
                    }
                }
                lastCpuTotal = total;
                lastCpuIdle = idleTime;
            }
        }
        Component.onCompleted: running = true
    }

    // Memory usage
    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 1;
                var used = parseInt(parts[2]) || 0;
                memUsage = Math.round(100 * used / total);
            }
        }
        Component.onCompleted: running = true
    }

    // Disk usage
    Process {
        id: diskProc
        command: ["sh", "-c", "df / | tail -1"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.trim().split(/\s+/);
                var percentStr = parts[4] || "0%";
                diskUsage = parseInt(percentStr.replace('%', '')) || 0;
            }
        }
        Component.onCompleted: running = true
    }

    // Volume level (wpctl for PipeWire)
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.split(' ');
                if (parts.length < 3) {
                    volumeLevel = Math.round(parseFloat(parts[1]) * 100);
                } else if (parts.length >= 3) {
                    volumeLevel = -1;
                }
            }
        }
        Component.onCompleted: running = true
    }

    // Active window title (sway)
    Process {
        id: windowProc
        command: ["sh", "-c", "swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .name // empty' | head -1"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    activeWindow = data.trim();
                }
            }
        }
        Component.onCompleted: running = true
    }

    // Battery
    Process {
        id: batteryProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT1/capacity"]
        stdout: SplitParser {
            onRead: data => {
                if (data)
                    batteryLevel = parseInt(data.trim());
            }
        }
        Component.onCompleted: running = true
    }

    // Notifications
    Process {
        id: notificationsProc
        command: ["sh", "-c", "dunstctl count history"]
        stdout: SplitParser {
            onRead: data => {
                if (data)
                    notificationHistory = parseInt(data.trim());
            }
        }
        Component.onCompleted: running = true
    }

    // Slow timer for system stats
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
            diskProc.running = true;
            batteryProc.running = true;
            notificationsProc.running = true;
        }
    }

    // Fast timer for window/layout
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            windowProc.running = true;
            volProc.running = true;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            property var currentWorkspaces: {
                var workspaces = I3.workspaces.values;
                var filtered = workspaces.filter(w => w.monitor.name == modelData.name);
                return filtered.sort((a, b) => a.number - b.number);
            }

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30
            color: Config.colors.base

            margins {
                top: 0
                bottom: 0
                left: 0
                right: 0
            }

            Rectangle {
                anchors.fill: parent
                color: Config.colors.base
                opacity: Config.colors.opacity

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        width: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        color: "transparent"

                        Image {
                            anchors.fill: parent
                            source: "icons/endevour.png"
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Item {
                        width: 8
                    }

                    Repeater {
                        model: currentWorkspaces

                        Rectangle {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: parent.height
                            color: "transparent"

                            readonly property int wsId: modelData.number
                            readonly property int focusedId: I3.focusedWorkspace ? I3.focusedWorkspace.number : -1
                            readonly property bool isActive: wsId === focusedId
                            readonly property bool isUrgent: modelData.urgent

                            GlowingText {
                                text: wsId
                                sourceColor: {
                                    if (isUrgent)
                                        return Config.colors.urgent;
                                    if (isActive)
                                        return Config.colors.highlight;
                                    return Config.colors.text;
                                }
                                glowColor: sourceColor
                                centerColor: "white"
                                pixelSize: root.fontSize
                                fontFamily: root.fontFamily
                                bold: true
                                glowRadius: 2
                                anchors.centerIn: parent
                            }

                            Rectangle {
                                width: 20
                                height: 3
                                color: isActive ? Config.colors.color6 : Config.colors.base
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    I3.dispatch("workspace " + wsId);
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        color: Config.colors.color0
                    }

                    GlowingText {
                        text: "🕭 " + notificationHistory
                        sourceColor: Config.colors.text
                        glowColor: sourceColor
                        centerColor: "white"
                        pixelSize: root.fontSize
                        fontFamily: root.fontFamily
                        bold: true
                        glowRadius: 2
                        Layout.leftMargin: 5
                        Layout.rightMargin: 5
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 2
                        Layout.rightMargin: 8
                        color: Config.colors.color0
                    }

                    GlowingText {
                        text: activeWindow
                        sourceColor: Config.colors.color5
                        glowColor: sourceColor
                        centerColor: "white"
                        pixelSize: root.fontSize
                        fontFamily: root.fontFamily
                        bold: true
                        glowRadius: 2
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    GlowingText {
                        text: kernelVersion
                        sourceColor: Config.colors.color1
                        glowColor: sourceColor
                        centerColor: "white"
                        pixelSize: root.fontSize
                        fontFamily: root.fontFamily
                        bold: true
                        glowRadius: 2
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: Config.colors.color0
                    }

                    GlowingText {
                        text: "CPU: " + cpuUsage + "%"
                        sourceColor: Config.colors.color3
                        glowColor: sourceColor
                        centerColor: "white"
                        pixelSize: root.fontSize
                        fontFamily: root.fontFamily
                        bold: true
                        glowRadius: 2
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: Config.colors.color0
                    }

                    GlowingText {
                        text: "Mem: " + memUsage + "%"
                        sourceColor: Config.colors.color6
                        glowColor: sourceColor
                        centerColor: "white"
                        pixelSize: root.fontSize
                        fontFamily: root.fontFamily
                        bold: true
                        glowRadius: 2
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: Config.colors.color0
                    }

                    GlowingText {
                        text: "Disk: " + diskUsage + "%"
                        sourceColor: Config.colors.color4
                        glowColor: sourceColor
                        centerColor: "white"
                        pixelSize: root.fontSize
                        fontFamily: root.fontFamily
                        bold: true
                        glowRadius: 2
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: Config.colors.color0
                    }

                    GlowingText {
                        text: {
                            if (volumeLevel === -1) {
                                return "Vol: " + "MUTE";
                            } else {
                                return "Vol: " + volumeLevel + "%";
                            }
                        }
                        sourceColor: Config.colors.color5
                        glowColor: sourceColor
                        centerColor: "white"
                        pixelSize: root.fontSize
                        fontFamily: root.fontFamily
                        bold: true
                        glowRadius: 2
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: Config.colors.color0
                    }

                    GlowingText {
                        text: "Bat: " + batteryLevel + "%"
                        sourceColor: Config.colors.color2
                        glowColor: sourceColor
                        centerColor: "white"
                        pixelSize: root.fontSize
                        fontFamily: root.fontFamily
                        bold: true
                        glowRadius: 2
                        Layout.rightMargin: 8
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: Config.colors.color0
                    }
                    SystemClock {
                        id: clock
                        precision: SystemClock.Seconds
                    }
                    GlowingText {
                        text: Qt.formatDateTime(clock.date, "ddd, MMM dd - HH:mm")
                        sourceColor: Config.colors.color6
                        glowColor: "white"
                        centerColor: "white"
                        pixelSize: root.fontSize
                        fontFamily: root.fontFamily
                        bold: true
                        glowRadius: 2
                        glowSpread: 0.4
                        Layout.rightMargin: 8
                    }

                    Item {
                        width: 8
                    }
                }
            }
        }
    }
}
