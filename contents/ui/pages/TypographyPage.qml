import ".." as Base
import "../components" as Components
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami 2.20 as Kirigami

Flickable {
    id: page

    property var cfg
    property Item edgeSafeContainer: null

    readonly property var weightLabels: [
        "Thin (100)",
        "Extra Light (200)",
        "Light (300)",
        "Normal (400)",
        "Medium (500)",
        "DemiBold (600)",
        "Bold (700)",
        "Extra Bold (800)",
        "Black (900)"
    ]
    readonly property var weightValues: [100, 200, 300, 400, 500, 600, 700, 800, 900]

    readonly property var iconSourceLabels: [
        "Follow Text / Dynamic",
        "System Theme",
        "Custom Color"
    ]

    function weightToIndex(w) {
        let val = Number(w) || 700;
        let bestIdx = 6;
        let bestDiff = 9999;
        for (let i = 0; i < weightValues.length; i++) {
            let diff = Math.abs(weightValues[i] - val);
            if (diff < bestDiff) {
                bestDiff = diff;
                bestIdx = i;
            }
        }
        return bestIdx;
    }

    function resolveColor(c) {
        let s = String(c || "").trim().toLowerCase();
        return (s === "" || s === "system" || s === "#ffffff" || s === "#fff") ? String(Kirigami.Theme.textColor) : c;
    }

    function previewIconColor(baseTextColor, isAlertState) {
        let condActive = isAlertState && (cfg.applyConditionsToIcon !== undefined ? cfg.applyConditionsToIcon : true);
        if (condActive)
            return Components.Theme.warningCol;

        let src = cfg.iconColorSource !== undefined ? cfg.iconColorSource : 0;
        if (src === 1)
            return Kirigami.Theme.textColor;
        if (src === 2)
            return resolveColor(cfg.customIconColor || "#ffffff");
        return baseTextColor;
    }

    contentHeight: typoCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColorDialog {
        id: iconColorDialog

        title: "Select Custom Icon Color"
        selectedColor: page.resolveColor(cfg.customIconColor || "#ffffff")
        onAccepted: {
            cfg.customIconColor = String(selectedColor);
        }
    }

    ColumnLayout {
        id: typoCol

        spacing: 18

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 24
        }

        // ═══════════════════════════════════════════════
        //  LIVE PREVIEW
        // ═══════════════════════════════════════════════
        Components.SectionLabel {
            text: "LIVE PREVIEW"
        }

        Components.Card {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(64, previewRow.implicitHeight + 24)
                    radius: 8
                    color: Qt.rgba(0, 0, 0, 0.25)
                    border.color: Components.Theme.borderCol
                    border.width: 1

                    RowLayout {
                        id: previewRow

                        anchors.centerIn: parent
                        spacing: 20

                        // Sample Item 1: CPU
                        RowLayout {
                            spacing: 4
                            Kirigami.Icon {
                                Layout.preferredWidth: Math.round(Kirigami.Units.iconSizes.small * ((cfg.fontSize || 10) / 10))
                                Layout.preferredHeight: Layout.preferredWidth
                                Layout.alignment: Qt.AlignVCenter
                                source: Qt.resolvedUrl("../../icons/cpu.svg")
                                isMask: true
                                color: page.previewIconColor(Kirigami.Theme.textColor, false)
                            }
                            Text {
                                text: "42%"
                                color: Kirigami.Theme.textColor
                                font.pointSize: cfg.fontSize || 10
                                font.family: cfg.fontFamily !== "" ? cfg.fontFamily : Kirigami.Theme.defaultFont.family
                                font.weight: cfg.fontWeight || Font.Bold
                                font.italic: cfg.fontItalic || false
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Sample Item 2: RAM (alert state)
                        RowLayout {
                            spacing: 4
                            Kirigami.Icon {
                                Layout.preferredWidth: Math.round(Kirigami.Units.iconSizes.small * ((cfg.fontSize || 10) / 10))
                                Layout.preferredHeight: Layout.preferredWidth
                                Layout.alignment: Qt.AlignVCenter
                                source: Qt.resolvedUrl("../../icons/memory.svg")
                                isMask: true
                                color: page.previewIconColor(Kirigami.Theme.textColor, true)
                            }
                            Text {
                                text: "5.8 GB"
                                color: (cfg.applyConditionsToText !== undefined ? cfg.applyConditionsToText : true) ? Components.Theme.warningCol : Kirigami.Theme.textColor
                                font.pointSize: cfg.fontSize || 10
                                font.family: cfg.fontFamily !== "" ? cfg.fontFamily : Kirigami.Theme.defaultFont.family
                                font.weight: cfg.fontWeight || Font.Bold
                                font.italic: cfg.fontItalic || false
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        // Sample Item 3: Network
                        RowLayout {
                            spacing: 4
                            Kirigami.Icon {
                                Layout.preferredWidth: Math.round(Kirigami.Units.iconSizes.small * ((cfg.fontSize || 10) / 10))
                                Layout.preferredHeight: Layout.preferredWidth
                                Layout.alignment: Qt.AlignVCenter
                                source: Qt.resolvedUrl("../../icons/down.svg")
                                isMask: true
                                color: page.previewIconColor(Components.Theme.accentCol, false)
                            }
                            Text {
                                text: "1.4 MB/s"
                                color: Components.Theme.accentCol
                                font.pointSize: cfg.fontSize || 10
                                font.family: cfg.fontFamily !== "" ? cfg.fontFamily : Kirigami.Theme.defaultFont.family
                                font.weight: cfg.fontWeight || Font.Bold
                                font.italic: cfg.fontItalic || false
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    color: Components.Theme.textTertiary
                    font.pixelSize: 11
                    text: {
                        let fam = cfg.fontFamily !== "" ? cfg.fontFamily : "System Default";
                        let sz = (cfg.fontSize || 10) + " pt";
                        let wtIdx = page.weightToIndex(cfg.fontWeight);
                        let wt = page.weightLabels[wtIdx];
                        let it = cfg.fontItalic ? ", Italic" : "";
                        return fam + " • " + sz + " • " + wt + it;
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════
        //  TYPOGRAPHY SETTINGS
        // ═══════════════════════════════════════════════
        Components.SectionLabel {
            text: "FONT"
        }

        Components.Card {
            Layout.fillWidth: true

            Components.SettingRow {
                label: "Size"

                Components.SpinBox {
                    from: 6
                    to: 48
                    value: cfg.fontSize || 10
                    onValueModified: cfg.fontSize = value
                }
            }

            Components.Divider {
            }

            Components.SettingRow {
                label: "Weight / Style"

                Components.ComboBox {
                    edgeSafeContainer: page.edgeSafeContainer
                    implicitWidth: 200
                    model: page.weightLabels
                    currentIndex: page.weightToIndex(cfg.fontWeight)
                    onActivated: function(i) {
                        cfg.fontWeight = page.weightValues[i];
                    }
                }
            }

            Components.Divider {
            }

            Components.SettingRow {
                label: "Italic"

                Components.Toggle {
                    checked: !!cfg.fontItalic
                    onToggled: cfg.fontItalic = checked
                }
            }

            Components.Divider {
            }

            Components.SettingRow {
                label: "Family"

                Components.ComboBox {
                    edgeSafeContainer: page.edgeSafeContainer
                    implicitWidth: 200
                    model: {
                        let f = Qt.fontFamilies();
                        f.unshift("System Default");
                        return f;
                    }
                    currentIndex: cfg.fontFamily === "" ? 0 : Math.max(0, model.indexOf(cfg.fontFamily))
                    onActivated: function(i) {
                        cfg.fontFamily = (i === 0) ? "" : model[i];
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════
        //  ICON COLORS & SOURCE
        // ═══════════════════════════════════════════════
        Components.SectionLabel {
            text: "ICON COLORS"
        }

        Components.Card {
            Layout.fillWidth: true

            Components.SettingRow {
                label: "Color Source"

                Components.ComboBox {
                    edgeSafeContainer: page.edgeSafeContainer
                    implicitWidth: 200
                    model: page.iconSourceLabels
                    currentIndex: cfg.iconColorSource !== undefined ? cfg.iconColorSource : 0
                    onActivated: function(i) {
                        cfg.iconColorSource = i;
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: (cfg.iconColorSource === 2)
                spacing: 12

                Components.Divider {
                }

                Text {
                    text: "CUSTOM ICON COLOR"
                    color: Components.Theme.textSecondary
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.topMargin: 4
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        id: systemIconChip
                        readonly property bool selected: String(cfg.customIconColor || "").trim().toLowerCase() === "system"
                        width: sysIconChipRow.implicitWidth + 16
                        height: 24
                        radius: 8
                        color: selected ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.05)
                        border.color: selected ? "white" : Qt.rgba(1, 1, 1, 0.15)
                        border.width: selected ? 2 : 1

                        RowLayout {
                            id: sysIconChipRow
                            anchors.centerIn: parent
                            spacing: 6

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: Kirigami.Theme.textColor
                            }

                            Text {
                                text: "System"
                                color: Components.Theme.textPrimary
                                font.pixelSize: 11
                                font.bold: systemIconChip.selected
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cfg.customIconColor = "system"
                        }
                    }

                    Repeater {
                        model: [Components.Theme.accentCol, Components.Theme.successCol, Components.Theme.warningCol, Components.Theme.dangerCol, "#0ea5e9", "#a855f7", "#ffffff"]

                        delegate: Components.ColorSwatch {
                            width: 24
                            height: 24
                            colorValue: modelData
                            border.color: String(cfg.customIconColor || "").toLowerCase() === String(modelData).toLowerCase() ? "white" : Qt.rgba(1, 1, 1, 0.15)
                            border.width: String(cfg.customIconColor || "").toLowerCase() === String(modelData).toLowerCase() ? 2 : 1
                            scale: String(cfg.customIconColor || "").toLowerCase() === String(modelData).toLowerCase() ? 1.15 : 1
                            onClicked: cfg.customIconColor = String(modelData)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Components.ColorSwatch {
                        colorValue: page.resolveColor(cfg.customIconColor || "#ffffff")
                        width: 36
                        height: 36
                        onClicked: {
                            iconColorDialog.selectedColor = page.resolveColor(cfg.customIconColor || "#ffffff");
                            iconColorDialog.open();
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        color: customIconField.activeFocus ? Components.Theme.activeBg : Qt.rgba(0, 0, 0, 0.1)
                        border.color: customIconField.activeFocus ? Components.Theme.accentCol : Components.Theme.controlBorder
                        radius: 6

                        TextInput {
                            id: customIconField
                            anchors.fill: parent
                            anchors.margins: 12
                            verticalAlignment: TextInput.AlignVCenter
                            color: Components.Theme.textPrimary
                            font.pixelSize: 12
                            text: cfg.customIconColor || "#ffffff"
                            onTextEdited: {
                                if (text.trim() !== "")
                                    cfg.customIconColor = text.trim();
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════
        //  DYNAMIC CONDITIONS (THRESHOLDS)
        // ═══════════════════════════════════════════════
        Components.SectionLabel {
            text: "DYNAMIC CONDITIONS (THRESHOLDS)"
        }

        Components.Card {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                Components.SettingRow {
                    label: "Color Text on Condition"

                    Components.Toggle {
                        checked: cfg.applyConditionsToText !== undefined ? cfg.applyConditionsToText : true
                        onToggled: cfg.applyConditionsToText = checked
                    }
                }

                Components.Divider {
                }

                Components.SettingRow {
                    label: "Color Icon on Condition"

                    Components.Toggle {
                        checked: cfg.applyConditionsToIcon !== undefined ? cfg.applyConditionsToIcon : true
                        onToggled: cfg.applyConditionsToIcon = checked
                    }
                }
            }
        }
    }
}
