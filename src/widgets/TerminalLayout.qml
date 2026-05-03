import QtQuick
import QtQuick.Controls

import org.mauikit.controls as Maui

Maui.SplitView
{
    id: control

    orientation: width >= 600 ? Qt.Horizontal : Qt.Vertical

    property string path : "$PWD"

    readonly property bool hasActiveProcess : count === 2 ?  contentModel.get(0).hasActiveProcess || contentModel.get(1).hasActiveProcess : currentItem.hasActiveProcess

    readonly property bool isCurrentTab : SwipeView.isCurrentItem

    readonly property string title : count === 2 ?  contentModel.get(0).title  + " - " + contentModel.get(1).title : currentItem.title

    Maui.Controls.title: title
    Maui.Controls.toolTipText: currentItem.session.currentDir
    Maui.Controls.color: currentItem.tabColor
    Maui.Controls.iconName: control.hasActiveProcess ? "run-build" : ""
    Maui.Controls.badgeText: count === 2 ? "[|]" : ""

    Action
    {
        id: _reviewAction
        text: i18n("View")
        onTriggered:
        {
            _layout.setCurrentIndex(control.SwipeView.index)
        }
    }

    function forceActiveFocus()
    {
        control.currentItem.forceActiveFocus()
    }

    Component
    {
        id: _terminalComponent

        Terminal
        {
            watchForSilence: settings.watchForSilence
            onTaskFinished: (commandName) =>
            {
                console.log("[station-debug][layout]", "taskFinished", "tabTitle=", control.title, "commandName=", commandName, "isCurrentTab=", control.isCurrentTab, "rootActive=", root.active, "alertProcess=", settings.alertProcess)
                if(settings.alertProcess)
                {
                    root.notifyProcessAlert("dialog-warning",
                                            i18n("Process Finished"),
                                            i18n("Command '%1' has finished in tab: %2", commandName, control.title),
                                            [_reviewAction],
                                            !control.isCurrentTab || !root.active)
                }
            }
            onSilenceWarning:
            {
                console.log("[station-debug][layout]", "silenceWarning", "tabTitle=", control.title, "isCurrentTab=", control.isCurrentTab, "rootActive=", root.active, "watchForSilence=", settings.watchForSilence)
                root.notifyProcessAlert("dialog-warning",
                                        i18n("Pending Process"),
                                        i18n("Running process '%1' has been inactive for more than 30 seconds.", title),
                                        [_reviewAction],
                                        !control.isCurrentTab || !root.active)
            }
        }
    }

    Component.onCompleted: split()

    function split()
    {
        console.log("[station-debug][layout]", "split requested", "count=", control.count, "path=", control.path, "title=", control.title)
        if(control.count === 2)
        {
            console.log("[station-debug][layout]", "split already exists, popping instead")
            pop()
            return
        }//close the innactive split

        control.addSplit(_terminalComponent, {'path': control.path});
        console.log("[station-debug][layout]", "split added", "newCount=", control.count)
    }

    function pop()
    {
        var index = control.currentIndex === 1 ? 0 : 1
        const splitItem = control.contentModel.get(index)
        console.log("[station-debug][layout]", "pop requested", "index=", index, "hasSplitItem=", !!splitItem, "hasActiveProcess=", splitItem ? splitItem.hasActiveProcess : false, "rawHasActiveProcess=", splitItem ? splitItem.rawHasActiveProcess : false, "foreground=", splitItem ? splitItem.foregroundProcessName : "", "preventClosing=", settings.preventClosing)
        if(control.contentModel.get(index).hasActiveProcess && settings.preventClosing)
        {            
            console.log("[station-debug][layout]", "opening confirmation dialog for split")
            openCloseDialog(index, control.closeSplit)
        }else
        {
            console.log("[station-debug][layout]", "closing split immediately")
            control.closeSplit(index)
        }
    }

    function closeCurrentView()
    {
        control.closeSplit(control.currentIndex)
    }
}
