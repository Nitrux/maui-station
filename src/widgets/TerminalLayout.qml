import QtQuick
import QtQuick.Controls

import org.mauikit.controls as Maui

Maui.SplitView
{
    id: control

    orientation: width >= 600 ? Qt.Horizontal : Qt.Vertical

    property string path : "$PWD"

    readonly property bool hasActiveProcess : count === 2 ?  contentModel.get(0).hasActiveProcess || contentModel.get(1).hasActiveProcess : (currentItem ? currentItem.hasActiveProcess : false)
    readonly property bool hasRootProcess : count === 2 ?  contentModel.get(0).hasRootProcess || contentModel.get(1).hasRootProcess : (currentItem ? currentItem.hasRootProcess : false)

    readonly property bool isCurrentTab : SwipeView.isCurrentItem

    readonly property string title : count === 2 ?  contentModel.get(0).title  + " - " + contentModel.get(1).title : (currentItem ? currentItem.title : "")
    readonly property color tabColor : hasRootProcess ? Maui.Theme.negativeBackgroundColor : "transparent"

    Maui.Controls.title: title
    Maui.Controls.toolTipText: currentItem ? currentItem.session.currentDir : ""
    Maui.Controls.color: tabColor
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
        if(control.count === 2)
        {
            pop()
            return
        }//close the innactive split

        control.addSplit(_terminalComponent, {'path': control.path});
    }

    function pop()
    {
        var index = control.currentIndex === 1 ? 0 : 1
        if(control.contentModel.get(index).hasActiveProcess && settings.preventClosing)
        {            
            openCloseDialog(index, control.closeSplit)
        }else
        {
            control.closeSplit(index)
        }
    }

    function closeCurrentView()
    {
        control.closeSplit(control.currentIndex)
    }
}
