pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentTheme: "default"

    // This binding automatically selects the current theme,
    // or falls back to 'default' if the selected theme doesn't exist.
    property var colors: themes[currentTheme] || themes['default'] // qmllint disable-next-line missing-property

    property var themes: {
        "default": {
            "base": "#1E1E2E",
            "shadow": "#181825",
            "highlight": "#BAC2DE",
            "urgent": "#F38BA8",
            "accent": "#89B4FA",
            "text": "#CDD6F4",
            "outline": "#181825",
            "outlineGradientFade": "#11111B",
            "defaultWallpaperPath": "",
            "color0": "#45475A",
            "color1": "#F38BA8",
            "color2": "#A6E3A1",
            "color3": "#F9E2AF",
            "color4": "#89B4FA",
            "color5": "#F5C2E7",
            "color6": "#94E2D5",
            "color7": "#BAC2DE",
            "color8": "#585B70",
            "color9": "#F38BA8",
            "color10": "#A6E3A1",
            "color11": "#F9E2AF",
            "color12": "#89B4FA",
            "color13": "#F5C2E7",
            "color14": "#94E2D5",
            "color15": "#A6ADC8",
            "opacity": 100.0
        }
        // "pywal" theme will be added here dynamically
    }

    // --- Pywal Theme Loader ---
    FileView {
        id: pywalJsonFile
        path: "file:///home/isac/.cache/wal/colors.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: this.reload()
    }
    readonly property var jsonData: JSON.parse(pywalJsonFile.text())
    Component.onCompleted: {
        // console.log(JSON.stringify(jsonData))
        if (jsonData && typeof jsonData === 'object') {
            // Create a new theme based on the default theme to inherit hardcoded values
            var walTheme = {};
            var defaultTheme = themes['default'];

            for (var key in defaultTheme) {
                walTheme[key] = defaultTheme[key];
            }

            // Override with values from jsonData
            if (jsonData.special) {
                if (jsonData.special.background)
                  walTheme.base = jsonData.special.background;
                if (jsonData.special.foreground)
                  walTheme.text = jsonData.special.foreground;
                if (jsonData.special.cursor)
                  walTheme.highlight = jsonData.special.cursor;
            }
            if (jsonData.wallpaper) {
                walTheme.defaultWallpaperPath = jsonData.wallpaper;
            }

            // Override the color palette
            if (jsonData.colors) {
                for (var i = 0; i <= 15; i++) {
                    var colorKey = "color" + i;
                    if (jsonData.colors[colorKey]) {
                        walTheme[colorKey] = jsonData.colors[colorKey];
                    }
                }
            }

            // Explicitly keep user-requested hardcoded colors
            walTheme.shadow = defaultTheme.shadow;
            walTheme.urgent = defaultTheme.urgent;
            walTheme.accent = walTheme[0];
            walTheme.outline = defaultTheme.outline;
            walTheme.outlineGradientFade = defaultTheme.outlineGradientFade;
            walTheme.opacity = 50.0
            // Add the new 'wal' theme to the themes object
            themes.wal = walTheme;

            // Set the current theme to "wal" to apply it
            currentTheme = "wal";
        }
    }
}
