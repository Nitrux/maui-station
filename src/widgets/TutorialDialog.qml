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
        description: i18n("Window-level shortcuts for managing tabs and opening Station dialogs.")

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
        description: i18n("Shortcuts that act on the active terminal tab or split.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Find")
            label2.text: i18n("Open the terminal search bar.")

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
            label2.text: i18n("Open or close a second split in the current tab.")

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
            label2.text: i18n("Move focus to the next split in the current tab.")

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
        description: i18n("On touch devices you can use the following gestures to navigate.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Up & Down")
            label2.text: i18n("Swipe up or down to navigate the commands history.")

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
            label1.text: i18n("Left & Right")
            label2.text: i18n("Swipe left or right to move through the command line to edit.")

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
            label1.text: i18n("Two Fingers Left & Right")
            label2.text: i18n("Swipe up or down with two fingers to scroll.")

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
