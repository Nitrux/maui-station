import QtQuick
import QtQuick.Controls

import org.mauikit.controls as Maui
import org.mauikit.terminal as Term

Maui.SplitViewItem
{
    id: control
    Maui.Controls.title: title
    Maui.Controls.badgeText: hasActiveProcess ? "!" : ""

    readonly property string shellProcessName : normalizedProcessName(session.shellProgram)
    readonly property string foregroundProcessName : normalizedProcessName(session.foregroundProcessName)
    readonly property bool rawHasActiveProcess : session.hasActiveProcess
    readonly property bool hasActiveProcess : rawHasActiveProcess
                                             && (foregroundProcessName.length === 0
                                                 || (isCommandProcessName(foregroundProcessName)
                                                     && !isBootstrapProcessName(foregroundProcessName)))

    property string path : "$HOME"
    property bool watchForSilence : false
    property string previousForegroundProcessName : ""
    property bool suppressTaskFinishedNotification : false
    property bool startupNotificationsSuppressed : true

    function forceActiveFocus()
    {
        if(control.kterminal)
        {
            control.kterminal.forceActiveFocus()
        }
    }

    function normalizedProcessName(processName)
    {
        let name = processName || ""

        if(name.indexOf("/") >= 0)
        {
            name = name.split("/").pop()
        }

        while(name.startsWith("-"))
        {
            name = name.slice(1)
        }

        return name.trim()
    }

    function isShellProcessName(processName)
    {
        const name = normalizedProcessName(processName)
        return name.length > 0 && name === shellProcessName
    }

    function isCommandProcessName(processName)
    {
        const name = normalizedProcessName(processName)
        return name.length > 0 && !isShellProcessName(name)
    }

    function isBootstrapProcessName(processName)
    {
        const name = normalizedProcessName(processName)
        return name === "stty"
                || name === "dircolors"
                || name === "tty"
                || name === "mesg"
    }

    enum TabTitle
    {
        ProcessName,
        WorkingDirectory,
        Auto
    }

    readonly property alias terminal : _terminal
    readonly property alias session : _terminal.session
    readonly property string title : switch(settings.tabTitleStyle)
                                     {
                                     case Terminal.TabTitle.ProcessName : return _terminal.session.foregroundProcessName
                                     case Terminal.TabTitle.WorkingDirectory : return _terminal.session.currentDir
                                     case Terminal.TabTitle.Auto : return terminal.title
                                     }
    readonly property alias kterminal : _terminal.kterminal

    property color tabColor : session.foregroundProcessName.startsWith("sudo") ? "red" : "transparent"

    signal silenceWarning()
    signal taskFinished(string commandName)

    background: null

    Component.onCompleted: previousForegroundProcessName = foregroundProcessName
    Component.onDestruction: suppressTaskFinishedNotification = true

    Timer
    {
        id: _startupNotificationTimer
        interval: 1500
        repeat: false
        running: true
        onTriggered:
        {
            control.startupNotificationsSuppressed = false
            console.log("[station-debug][terminal]", "startup notification suppression ended", "path=", control.path, "foreground=", control.foregroundProcessName, "rawHasActiveProcess=", control.rawHasActiveProcess)
        }
    }

    Term.Terminal
    {
        id: _terminal
        background: null

        anchors.fill: parent

        session.initialWorkingDirectory : control.path
        session.historySize: settings.historySize
        session.monitorSilence: control.watchForSilence

        onUrlsDropped: (urls) =>
                       {
                           for(var i in urls)
                           control.session.sendText((urls[i]).toString().replace("file://", "")+ " ")
                       }

        kterminal.font: settings.font
        kterminal.colorScheme: settings.colorScheme
        kterminal.lineSpacing: settings.lineSpacing
        kterminal.backgroundOpacity: settings.windowTranslucency ? 0 : 1
        showFindContextMenuAction: false

        menu: [
            MenuItem
            {
                text: i18n("Open Current Location")
                icon.name: "folder"
                onTriggered: Qt.openUrlExternally("file://"+session.currentDir)
            },

            MenuSeparator
            {
                visible: kterminal.isTextSelected
                height: visible ? implicitHeight : 0
            },

            MenuItem
            {
                enabled: kterminal.isTextSelected && Maui.Handy.isEmail(kterminal.selectedText())
                visible: enabled
                height: visible ? implicitHeight : 0
                text: i18n("Email")
                icon.name: "mail"
                onTriggered: Qt.openUrlExternally("mailto="+kterminal.selectedText())
            },

            MenuItem
            {
                enabled: kterminal.isTextSelected
                visible: enabled
                height: visible ? implicitHeight : 0
                text: i18n("Search Web")
                icon.name: "webpage-symbolic"
                onTriggered: Qt.openUrlExternally("https://www.google.com/search?q="+kterminal.selectedText())
            }
        ]

        Connections
        {
            target: _terminal.session

            function onBellRequest(message)
            {
                console.log("Bell REQUESTED!!!", message);
            }

            function onProcessHasSilent(value)
            {
                console.log("[station-debug][terminal]", "process silence state", "path=", control.path, "value=", value, "rawHasActiveProcess=", control.rawHasActiveProcess, "hasActiveProcess=", control.hasActiveProcess, "foreground=", control.foregroundProcessName)
                if(control.watchForSilence && value && control.hasActiveProcess)
                    control.silenceWarning()
            }

            function onHasActiveProcessChanged()
            {
                console.log("[station-debug][terminal]", "hasActiveProcessChanged", "path=", control.path, "rawHasActiveProcess=", control.rawHasActiveProcess, "hasActiveProcess=", control.hasActiveProcess, "foreground=", control.foregroundProcessName, "previousForeground=", control.previousForegroundProcessName)
            }

            function onForegroundProcessNameChanged()
            {
                const process = control.foregroundProcessName
                const previousProcess = control.previousForegroundProcessName
                const shouldNotify = !control.suppressTaskFinishedNotification
                        && !control.startupNotificationsSuppressed
                        && control.isCommandProcessName(previousProcess)
                        && !control.isBootstrapProcessName(previousProcess)
                        && control.isShellProcessName(process)

                console.log("[station-debug][terminal]", "foregroundProcessNameChanged",
                            "path=", control.path,
                            "previous=", previousProcess,
                            "current=", process,
                            "shell=", control.shellProcessName,
                            "rawHasActiveProcess=", control.rawHasActiveProcess,
                            "hasActiveProcess=", control.hasActiveProcess,
                            "startupNotificationsSuppressed=", control.startupNotificationsSuppressed,
                            "suppressTaskFinishedNotification=", control.suppressTaskFinishedNotification,
                            "shouldNotify=", shouldNotify)

                if(shouldNotify)
                {
                    control.taskFinished(previousProcess)
                }

                switch (process)
                {
                case "nano" : settings.keysModelCurrentIndex = 1; break;
                case "htop" : settings.keysModelCurrentIndex = 0; break;
                }

                control.previousForegroundProcessName = process
            }

            function onFinished()
            {
                control.suppressTaskFinishedNotification = true
                console.log("[station-debug][terminal]", "session finished", "path=", control.path, "currentTabCount=", currentTab.count, "foreground=", control.foregroundProcessName, "rawHasActiveProcess=", control.rawHasActiveProcess)
                console.log("ASKED TO CLOSE SESSION")
                if(currentTab.count === 1)
                {
                    closeTab(currentTabIndex)
                }else
                {
                    closeSplit()
                }
            }
        }
    }
}
