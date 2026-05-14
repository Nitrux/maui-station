import QtQuick
import QtCore

import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.terminal as Term
import org.mauikit.filebrowsing as FB
import org.maui.station as Station

import "widgets"

Maui.ApplicationWindow
{
    id: root
    color: "transparent"
    background: null

    title: currentTerminal? currentTerminal.session.title : ""

    readonly property alias currentTab : _layout.currentItem

    readonly property Term.Terminal currentTerminal : currentTab && currentTab.currentItem ? currentTab.currentItem.terminal : null
    readonly property font defaultFont : Maui.Style.monospacedFont
    readonly property alias currentTabIndex : _layout.currentIndex

    Maui.WindowBlur
    {
        view: root
        geometry: Qt.rect(0, 0, root.width, root.height)
        windowRadius: Maui.Style.radiusV
        enabled: true
    }

    Rectangle
    {
        anchors.fill: parent
        color: Maui.Theme.backgroundColor
        opacity: 0.76
        radius: Maui.Style.radiusV
        border.color: Qt.rgba(1, 1, 1, 0)
        border.width: 1
    }

    property bool discard : false
    onClosing: (close) =>
               {
                   close.accepted = !settings.restoreSession
                   root.saveSession()

                   if(anyTabHasActiveProcess() && settings.preventClosing && !root.discard)
                   {
                       openCloseDialog(-1, ()=> {root.discard = true; root.close();})
                       close.accepted = false
                       return
                   }

                   close.accepted = true
               }


    Settings
    {
        id: settings
        property string colorScheme: "Maui-Dark"

        property int lineSpacing : 0
        property int historySize : 1000

        property font font : defaultFont
        property int keysModelCurrentIndex : 4

        property double windowOpacity: 0.8
        property bool windowTranslucency: false

        property bool preventClosing: true
        property bool alertProcess: true

        property bool showSignalBar: false
        property bool watchForSilence: false

        property bool restoreSession : false
        property var lastSession: []
        property int lastTabIndex : 0
        property int tabTitleStyle: Terminal.TabTitle.Auto
    }

    Component
    {
        id: _shortcutsDialogComponent
        TutorialDialog
        {
            onClosed: destroy()
        }
    }

    Component
    {
        id: _settingsDialogComponent
        SettingsDialog
        {
            onClosed: destroy()
        }
    }

    Maui.Notify
    {
        id: _processNotify
        componentName: "org.kde.station"
        eventId: "processAlert"
    }

    Component
    {
        id: _tabsCounterButtonComponent
        ToolButton
        {
            text: _layout.count
            display: ToolButton.TextOnly
            font.bold: true
            font.pointSize: Maui.Style.fontSizes.small
            onClicked: _layout.openOverview()

            background: Rectangle
            {
                color: Maui.Theme.alternateBackgroundColor
                radius: Maui.Style.radiusV
            }

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Tab Overview")
        }
    }

    Shortcut
    {
        sequence: "Ctrl+Shift+T"
        context: Qt.ApplicationShortcut
        onActivated: root.openTab("$PWD")
    }

    Shortcut
    {
        sequence: "Ctrl+Shift+E"
        context: Qt.ApplicationShortcut
        enabled: !!root.currentTab
        onActivated: root.currentTab.split()
    }

    Shortcut
    {
        sequence: "Ctrl+Shift+F"
        context: Qt.ApplicationShortcut
        enabled: !!root.currentTerminal
        onActivated: root.currentTerminal.toggleSearchBar()
    }

    Shortcut
    {
        sequence: "F6"
        context: Qt.ApplicationShortcut
        enabled: !!root.currentTab && root.currentTab.count > 1
        onActivated: root.focusNextSplit()
    }

    Shortcut
    {
        sequence: "Ctrl+Shift+W"
        context: Qt.ApplicationShortcut
        enabled: _layout.count > 0
        onActivated: root.closeTab(root.currentTabIndex)
    }

    Shortcut
    {
        sequence: "Ctrl+/"
        context: Qt.ApplicationShortcut
        onActivated: root.openShortcutsDialog()
    }

    Shortcut
    {
        sequence: "Ctrl+,"
        context: Qt.ApplicationShortcut
        onActivated: root.openSettingsDialog()
    }

    Maui.SideBarView
    {
        id: _sideBarView
        anchors.fill: parent

        sideBar.autoShow: false
        sideBar.autoHide: true
        sideBar.collapsed: !root.isWide

        background: null

        sideBarContent: Loader
        {
            id: _sideBarLoader
            anchors.fill: parent
            anchors.margins: Maui.Style.defaultPadding

            active: false
            asynchronous: true
            sourceComponent: Maui.Page
            {
                property alias shortcutsPage : _shortcutsPage
                background: null

                Rectangle
                {
                    anchors.fill: parent
                    color: Maui.Theme.alternateBackgroundColor
                    radius: Maui.Style.radiusV
                    opacity: _layout.count === 0 ? 1 : (settings.windowTranslucency ? settings.windowOpacity : 1)
                    border.color:  Maui.Theme.backgroundColor
                }

                headerMargins: Maui.Style.defaultPadding
                headBar.middleContent: Maui.ToolActions
                {
                    autoExclusive: true
                    Layout.alignment: Qt.AlignHCenter
                    display: ToolButton.IconOnly

                    Action
                    {
                        text: i18n("Commands")
                        icon.name: "terminal-symbolic"
                        checked: _swipeView.currentIndex === 0
                        onTriggered: _swipeView.setCurrentIndex(0)
                    }

                    Action
                    {
                        text: i18n("Bookmarks")
                        icon.name:"folder"
                        checked: _swipeView.currentIndex === 1
                        onTriggered: _swipeView.setCurrentIndex(1)

                    }
                }

                SwipeView
                {
                    id: _swipeView
                    anchors.fill: parent
                    background: null

                        CommandShortcuts
                        {
                            id: _shortcutsPage
                            background: null
                            onCommandTriggered: (command, autorun) =>
                                                {
                                                    if(!root.currentTerminal || !root.currentTerminal.session)
                                                    {
                                                        return
                                                    }

                                                    root.currentTerminal.session.sendText("\x05\x15")

                                                    root.currentTerminal.session.sendText(command)

                                                    if(autorun)
                                                    {
                                                        root.currentTerminal.session.sendText("\r")
                                                    }

                                                    if(_sideBarView.sideBar.peeking)
                                                    {
                                                        _sideBarView.sideBar.close()
                                                    }

                                                    root.currentTerminal.forceActiveFocus()
                                                }
                        }


                    Maui.Page
                    {
                        id: _bookmarksPage
                        headBar.visible: false
                        background: null

                        FB.PlacesListBrowser
                        {
                            currentPath: root.currentTerminal && root.currentTerminal.session ? "file://" + root.currentTerminal.session.currentDir : "file://"

                            anchors.fill: parent
                            onPlaceClicked:  (path) =>
                                             {
                                                 if(root.currentTerminal && root.currentTerminal.session)
                                                 {
                                                     root.currentTerminal.session.changeDir(path.replace("file://", ""))
                                                 }

                                                 // root.currentTerminal.forceActiveFocus()
                                             }
                        }
                    }
                }
            }
        }

        Maui.Page
        {
            anchors.fill: parent
            headBar.visible: false
            background: null

            Maui.TabView
            {
                id: _layout
                clip: true
                background: null
                altTabBar: Maui.Handy.isMobile
                Maui.Controls.showCSD: true

                anchors.fill: parent

                onNewTabClicked: root.openTab("$PWD")
                onCloseTabClicked:(index) => root.closeTab(index)
                tabViewButton: Maui.TabViewButton
                {
                    id: _tabButton
                    tabView: _layout
                    closeButtonVisible: !_layout.mobile
                    // Hide the built-in color strip so we can locally tune its thickness.
                    color: "transparent"

                    readonly property bool _isSuperUserTab : tabInfo.color
                                                            && tabInfo.color.toString() === Maui.Theme.negativeBackgroundColor.toString()

                    Rectangle
                    {
                        parent: _tabButton.background
                        color: _tabButton.tabInfo.color ? _tabButton.tabInfo.color : "transparent"
                        height: _tabButton._isSuperUserTab ? 1 : 2
                        width: parent.width * 0.9
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    onClicked:
                    {
                        _layout.setCurrentIndex(_tabButton.mindex)

                        if(_layout.currentItem)
                        {
                            _layout.currentItem.forceActiveFocus()
                        }
                    }

                    onRightClicked: _layout.openTabMenu(_tabButton.mindex)
                    onCloseClicked: _layout.closeTabClicked(_tabButton.mindex)
                }

                tabBarMargins: Maui.Style.defaultPadding
                tabBar.showNewTabButton: false
                tabBar.visible: true
                tabBar.background: Rectangle
                {
                    color: Maui.Theme.backgroundColor
                    opacity: settings.windowTranslucency ? settings.windowOpacity : 1
                    radius: Maui.Style.radiusV
                }

                tabBar.leftContent: [
                    ToolButton
                    {
                        icon.name: "tab-new"
                        display: ToolButton.IconOnly
                        Maui.Controls.toolTipText: i18n("New Tab")
                        onClicked: root.openTab("$PWD")
                    },

                    ToolButton
                    {
                        enabled: !!root.currentTab
                        checkable: true
                        checked: enabled && root.currentTab.count === 2
                        icon.name: root.currentTab && root.currentTab.orientation === Qt.Horizontal ? "view-split-left-right" : "view-split-top-bottom"
                        display: ToolButton.IconOnly
                        Maui.Controls.toolTipText: i18n("Split")
                        onClicked:
                        {
                            if(root.currentTab)
                            {
                                root.currentTab.split()
                            }
                        }
                    },

                    ToolSeparator
                    {
                        visible: _layout.count > 0
                        topPadding: 10
                        bottomPadding: 10
                    },

                    Loader
                    {
                        active: _layout.count > 1
                        visible: active
                        asynchronous: true
                        sourceComponent: _tabsCounterButtonComponent
                    },

                    ToolSeparator
                    {
                        visible: _layout.count > 1
                        topPadding: 10
                        bottomPadding: 10
                    }
                ]

                tabBar.rightContent: [
                    ToolSeparator
                    {
                        visible: _layout.count > 0
                        topPadding: 10
                        bottomPadding: 10
                    },

                    ToolButton
                    {
                        icon.name: "edit-find"
                        display: ToolButton.IconOnly
                        Maui.Controls.toolTipText: i18n("Search")
                        checked: root.currentTerminal ? root.currentTerminal.footBar.visible : false
                        onClicked:
                        {
                            if(root.currentTerminal)
                            {
                                root.currentTerminal.toggleSearchBar()
                            }
                        }
                    },

                    ToolSeparator
                    {
                        visible: _layout.count > 0
                        topPadding: 10
                        bottomPadding: 10
                    },

                    Maui.ToolButtonMenu
                    {
                        icon.name: "overflow-menu"

                        MenuItem
                        {
                            text: i18n("Shortcuts")
                            icon.name: "configure-shortcuts"
                            onTriggered: root.openShortcutsDialog()
                        }

                        MenuItem
                        {
                            icon.name: "settings-configure"
                            text: i18n("Settings")
                            onTriggered: root.openSettingsDialog()
                        }

                        MenuItem
                        {
                            text: i18n("About")
                            icon.name: "documentinfo"
                            onTriggered: Maui.App.aboutDialog()
                        }
                    }
                ]

            }

            Maui.Holder
            {
                anchors.fill: parent
                visible: _layout.count === 0
                emoji: "utilities-terminal"
                title: i18n("Run a Command")
                body: i18n("Open a new tab or split view to start exectuing commands.")
            }

            footBar.visible: Maui.Handy.isMobile || Maui.Handy.isTouch
            footerContainer.margins: Maui.Style.contentMargins
            footerContainer.topMargin: 0

            footBar.farRightContent: Loader
            {
                asynchronous: true
                sourceComponent: Maui.ToolButtonMenu
                {
                    icon.name: "overflow-menu"
                    MenuItem
                    {
                        text: i18n("Function Keys")
                        autoExclusive: true
                        checked: settings.keysModelCurrentIndex === 0
                        checkable: true
                        onTriggered: settings.keysModelCurrentIndex = 0
                    }

                    MenuItem
                    {
                        text: i18n("Nano")
                        autoExclusive: true
                        checked: settings.keysModelCurrentIndex === 1
                        checkable: true
                        onTriggered: settings.keysModelCurrentIndex = 1
                    }

                    MenuItem
                    {
                        text: i18n("Ctrl Modifiers")
                        autoExclusive: true
                        checked: settings.keysModelCurrentIndex === 2
                        checkable: true
                        onTriggered: settings.keysModelCurrentIndex = 2
                    }

                    MenuItem
                    {
                        text: i18n("Navigation")
                        autoExclusive: true
                        checked: settings.keysModelCurrentIndex === 3
                        checkable: true
                        onTriggered: settings.keysModelCurrentIndex = 3
                    }

                    MenuItem
                    {
                        text: i18n("Favorite")
                        autoExclusive: true
                        checked: settings.keysModelCurrentIndex === 4
                        checkable: true
                        onTriggered: settings.keysModelCurrentIndex = 4
                    }

                    MenuItem
                    {
                        text: i18n("Signals")
                        autoExclusive: true
                        checked: settings.keysModelCurrentIndex === 5
                        checkable: true
                        onTriggered: settings.keysModelCurrentIndex = 5
                    }

                    MenuSeparator {}

                    MenuItem
                    {
                        text: i18n("More Signals")
                        checked: settings.showSignalBar
                        checkable: true
                        onTriggered: settings.showSignalBar = !settings.showSignalBar
                    }
                }
            }

            footerColumn: Maui.ToolBar
            {
                visible: settings.showSignalBar
                width: parent ? parent.width : 0
                position: ToolBar.Footer

                Repeater
                {
                    model: _keysModel.signalsGroup

                    delegate:  Button
                    {
                        font.bold: true
                        text: modelData.label + "/ " + modelData.signal

                        onClicked:
                        {
                            if(currentTerminal && currentTerminal.session)
                            {
                                currentTerminal.session.sendSignal(9)
                            }
                        }

                        activeFocusOnTab: false
                        focusPolicy: Qt.NoFocus
                        autoRepeat: true
                    }
                }
            }

            footBar.leftContent: [
                Repeater
                {
                    model: Station.KeysModel
                    {
                        id: _keysModel
                        group: settings.keysModelCurrentIndex
                    }

                    Button
                    {
                        font.bold: true
                        text: model.label
                        icon.name: model.iconName

                        onClicked:
                        {
                            if(currentTerminal)
                            {
                                _keysModel.sendKey(index, currentTerminal.kterminal)
                            }
                        }

                        activeFocusOnTab: false
                        focusPolicy: Qt.NoFocus
                        autoRepeat: true
                    }
                }
            ]
        }
    }

    Component
    {
        id: _terminalComponent
        TerminalLayout {}
    }

    Component
    {
        id:  _confirmCloseDialogComponent
        Maui.InfoDialog
        {
            id : _confirmCloseDialog

            property var cb : ({})
            property int index: -1

            // title: i18n("Close")
            message: i18n("A process is still running. Are you sure you want to interrupt it and close it?")

            template.iconSource: "dialog-warning"
            template.iconVisible: true
            template.iconSizeHint: Maui.Style.iconSizes.huge

            standardButtons: Dialog.Ok | Dialog.Cancel

            onAccepted:
            {
                _confirmCloseDialog.close()

                if(cb instanceof Function)
                {
                    cb(index)
                }

            }

            onRejected:
            {
                close()
            }
        }
    }

    Component
    {
        id: _restoreDialogComponent
        Maui.InfoDialog
        {
            message: i18n("Do you want to restore the previous session?")
            standardButtons: Dialog.Ok | Dialog.Cancel
            template.iconSource: "dialog-question"
            onClosed: destroy()
            onAccepted:
            {
                const tabs = settings.lastSession
                if(tabs.length)
                {
                    restoreSession(tabs)
                    return
                }
            }
        }
    }

    Component.onCompleted:
    {
        if(settings.restoreSession)
        {
            var dialog = _restoreDialogComponent.createObject(root)
            dialog.open()
            return
        }
    }

    function openTab(path : string)
    {
        _layout.addTab(_terminalComponent, {'path': path});
        _layout.currentIndex = _layout.count -1
    }

    function focusNextSplit()
    {
        if(!root.currentTab || root.currentTab.count <= 1)
        {
            return
        }

        root.currentTab.incrementCurrentIndex()
        Qt.callLater(function()
        {
            if(root.currentTerminal)
            {
                root.currentTerminal.forceActiveFocus()
            }
        })
    }

    function openShortcutsDialog()
    {
        var dialog = _shortcutsDialogComponent.createObject(root)
        dialog.open()
    }

    function openSettingsDialog()
    {
        var dialog = _settingsDialogComponent.createObject(root)
        dialog.open()
    }

    function notifyProcessAlert(icon, title, body, actions, systemNotification)
    {
        root.notify(icon, title, body, actions)

        if(systemNotification)
        {
            _processNotify.iconName = icon
            _processNotify.title = title
            _processNotify.message = body
            _processNotify.send()
        }
    }

    function closeTab(index)
    {
        var tab = _layout.tabAt(index)

        if(tab && tab.hasActiveProcess && settings.preventClosing)
        {
            openCloseDialog(index, _layout.closeTab)
            return
        }

        _layout.closeTab(index)
    }

    function anyTabHasActiveProcess()
    {
        for(var i = 0; i < _layout.count; i++)
        {
            let tab = _layout.tabAt(i)
            if(tab && tab.hasActiveProcess)
            {
                return true
            }
        }

        return false
    }

    function saveSession()
    {
        var tabs = [];

        for(var i = 0; i < _layout.count; i ++)
        {
            var tab = _layout.contentModel.get(i)
            var tabPaths = []

            for(var j = 0; j < tab.count; j ++)
            {
                const term = tab.contentModel.get(j)
                if(!term || !term.session)
                {
                    continue
                }

                var path = String(term.session.currentDir)
                const tabMap = {'path': path}

                tabPaths.push(tabMap)
            }

            tabs.push(tabPaths)
        }

        settings.lastSession = tabs

        // settings.lastTabIndex = currentTabIndex
    }

    function restoreSession(tabs)
    {
        for(var i = 0; i < tabs.length; i++ )
        {
            const tab = tabs[i]

            if(tab.length === 2)
            {
                root.openTab(tab[0].path, tab[1].path)
            }else
            {
                root.openTab(tab[0].path)
            }
        }

        // currentTabIndex = settings.lastTabIndex
    }

    function openCloseDialog(index, cb)
    {
        var props = ({
                         'index' : index,
                         'cb' : cb
                     })
        var dialog = _confirmCloseDialogComponent.createObject(root, props)
        dialog.open()
    }
}
