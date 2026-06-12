import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui

Maui.SettingsDialog
{
    id: control

    Maui.Controls.title: i18n("Shortcuts")

    Maui.SectionGroup
    {
        Layout.fillWidth: true
        title: i18n("General")

        Maui.FlexSectionItem
        {
            label1.text: i18n("New Tab")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false

                Action { text: "Ctrl" }
                Action { text: "Shift" }
                Action { text: "T" }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Close Tab")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false

                Action { text: "Ctrl" }
                Action { text: "Shift" }
                Action { text: "W" }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Show Shortcuts")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false

                Action { text: "Ctrl" }
                Action { text: "/" }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Settings")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false

                Action { text: "Ctrl" }
                Action { text: "," }
            }
        }
    }

    Maui.SectionGroup
    {
        Layout.fillWidth: true
        title: i18n("Terminal")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Find")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false

                Action { text: "Ctrl" }
                Action { text: "Shift" }
                Action { text: "F" }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Toggle Split View")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false

                Action { text: "Ctrl" }
                Action { text: "Shift" }
                Action { text: "E" }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Next Split")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false

                Action { text: "F6" }
            }
        }
    }

    Maui.SectionGroup
    {
        Layout.fillWidth: true
        title: i18n("Navigation")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Up and Down")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false

                Action { text: i18n("Swipe") }
                Action { text: i18n("Up") }
                Action { text: i18n("Down") }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Left and Right")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false

                Action { text: i18n("Swipe") }
                Action { text: i18n("Left") }
                Action { text: i18n("Right") }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Two Fingers Left and Right")

            Maui.ToolActions
            {
                checkable: false
                autoExclusive: false

                Action { text: i18n("2 Fingers") }
                Action { text: i18n("Swipe") }
                Action { text: i18n("Up") }
                Action { text: i18n("Down") }
            }
        }
    }

}
