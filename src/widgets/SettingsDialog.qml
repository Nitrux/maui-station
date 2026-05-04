import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.terminal as Term

Maui.SettingsDialog
{
    id: control

    Component
    {
        id:_fontPageComponent

        Maui.SettingsPage
        {
            title: i18n("Font")

            Maui.FontPicker
            {
                Layout.fillWidth: true

                mfont: settings.font
                model.onlyMonospaced: true

                onFontModified: function(selectedFont)
                {
                    settings.font = selectedFont
                }
            }
        }
    }

    Component
    {
        id:_csPageComponent
        
        Term.ColorSchemesPage
        {
            currentColorScheme: settings.colorScheme
            onCurrentColorSchemeChanged: settings.colorScheme = currentColorScheme
        }
    }

    Component
    {
        id: _alertsPageComponent

        Maui.SettingsPage
        {
            title: i18n("Tasks")

            Maui.FlexSectionItem
            {
                label1.text: i18n("Protect Running Tasks")
                label2.text: i18n("Ask before closing a tab or split that still has a running task.")

                Switch
                {
                    checked: settings.preventClosing
                    onToggled:
                    {
                        settings.preventClosing = checked
                        if(checked)
                        {
                            settings.watchForSilence = false
                        }
                    }
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18n("Finished Task")
                label2.text: i18n("Show a toast and send a system notification when a running task finishes.")

                Switch
                {
                    checked: settings.alertProcess
                    onToggled:
                    {
                        settings.alertProcess = checked
                        if(checked)
                        {
                            settings.watchForSilence = false
                        }
                    }
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18n("Silent Process")
                label2.text: i18n("Show an alert when a running task has produced no output for more than 30 seconds.")

                Switch
                {
                    checked: settings.watchForSilence
                    onToggled:
                    {
                        settings.watchForSilence = checked
                        if(checked)
                        {
                            settings.preventClosing = false
                            settings.alertProcess = false
                        }
                    }
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Interface")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Translucency")
            label2.text: i18n("Translucent background.")

            Switch
            {
                checked: settings.windowTranslucency
                onToggled: settings.windowTranslucency = !settings.windowTranslucency
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Tab Title")

            Maui.ToolActions
            {
                autoExclusive: true

                Action
                {
                    text: i18n("Auto")
                    onTriggered: settings.tabTitleStyle = Terminal.TabTitle.Auto
                    checked: settings.tabTitleStyle === Terminal.TabTitle.Auto
                }

                Action
                {
                    text: i18n("Process")
                    onTriggered: settings.tabTitleStyle = Terminal.TabTitle.ProcessName
                    checked: settings.tabTitleStyle === Terminal.TabTitle.ProcessName
                }

                Action
                {
                    text: i18n("Directory")
                    onTriggered: settings.tabTitleStyle = Terminal.TabTitle.WorkingDirectory
                    checked: settings.tabTitleStyle === Terminal.TabTitle.WorkingDirectory
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Terminal")
//        description: i18n("Configure the app UI and plugins.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Save Session")
            label2.text: i18n("Restore previous session on startup.")

            Switch
            {
                checkable: true
                checked:  settings.restoreSession
                onToggled: settings.restoreSession = ! settings.restoreSession
            }

        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Color Scheme")
            label2.text: i18n("Change the color scheme of the terminal.")

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: control.addPage(_csPageComponent)
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Tasks")
            label2.text: i18n("Notifications and safeguards for running processes.")

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: control.addPage(_alertsPageComponent)
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Display")
//        description: i18n("Configure the terminal font and display options.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Font")
            label2.text: i18n("Font family and size.")

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: control.addPage(_fontPageComponent)
            }
        }

        Maui.FlexSectionItem
        {
            label1.text:  i18n("Line Spacing")

            SpinBox
            {
                from: 0; to : 500
                value: settings.lineSpacing
                onValueChanged: settings.lineSpacing = value
            }
        }

        Maui.FlexSectionItem
        {
            label1.text:  i18n("History Size")
            label2.text: i18n("Choose whether to keep no scrollback, 1,000 lines, or an unlimited history.")

            ComboBox
            {
                model: [
                    i18n("Off"),
                    i18n("1,000 Lines"),
                    i18n("Infinite")
                ]
                currentIndex: settings.historySize < 0 ? 2 : (settings.historySize === 0 ? 0 : 1)
                onActivated:
                {
                    switch (currentIndex)
                    {
                    case 0:
                        settings.historySize = 0
                        break
                    case 1:
                        settings.historySize = 1000
                        break
                    default:
                        settings.historySize = -1
                        break
                    }
                }
            }
        }
    }
}
