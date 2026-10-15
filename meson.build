project('station', 'cpp', version: '4.0.5', meson_version: '>=1.12.0', default_options: ['cpp_std=c++17', 'buildtype=release'])
qt6 = import('qt6')
cpp_compiler = meson.get_compiler('cpp')
if cpp_compiler.get_id() == 'gcc' and cpp_compiler.has_argument('-Wno-sfinae-incomplete')
    add_project_arguments('-Wno-sfinae-incomplete', language: 'cpp')
endif
qt = dependency('qt6', version: '>=6.9', modules: ['Core', 'Qml', 'Quick', 'Widgets', 'DBus'])
kf6_core = declare_dependency(
    include_directories: include_directories(get_option('prefix') / 'include' / 'KF6' / 'KCoreAddons'),
    dependencies: [cpp_compiler.find_library('KF6CoreAddons')],
)
kf6_i18n = declare_dependency(
    include_directories: include_directories(get_option('prefix') / 'include' / 'KF6' / 'KI18n'),
    dependencies: [cpp_compiler.find_library('KF6I18n'), cpp_compiler.find_library('KF6I18nQml')],
)
mauikit = dependency('MauiKit4', version: '>=4.0.5')
terminal = dependency('MauiKitTerminal4', version: '>=4.0.5')
filebrowsing = dependency('MauiKitFileBrowsing4', version: '>=4.0.5')
cpp_args = ['-DAPP_COPYRIGHT_NOTICE="© 2019-2025 Maui Development Team"']
if host_machine.cpu_family() == 'x86_64'
    cpp_args += ['-march=x86-64-v3']
endif
station_version = configure_file(
    input: 'meson-content.in',
    output: 'station_version.h',
    configuration: {'CONTENT': ('''#pragma once
#define STATION_VERSION_STRING "4.0.5"
#define GIT_BRANCH "Stable"
#define GIT_COMMIT_HASH "4.0.5"
''')}
)
station_includes = include_directories('src')
dbus_cpp2xml = find_program('qdbuscpp2xml')
dbus_xml2cpp = find_program('qdbusxml2cpp')
dbus_xml = custom_target('station-dbus-xml', input: 'src/server/server.h', output: 'org.kde.Station.xml', command: [dbus_cpp2xml, '-o', '@OUTPUT@', '@INPUT@'])
dbus_adaptor = custom_target('station-dbus-adaptor', input: dbus_xml, output: ['stationadaptor.cpp', 'stationadaptor.h'], command: [dbus_xml2cpp, '-a', 'stationadaptor', '@INPUT@'])
dbus_interface = custom_target('station-dbus-interface', input: dbus_xml, output: ['stationinterface.cpp', 'stationinterface.h'], command: [dbus_xml2cpp, '-p', 'stationinterface', '@INPUT@'])
station_sources = ['src/main.cpp', 'src/helpers/station.cpp', 'src/helpers/keyshelper.cpp', 'src/helpers/commandsmodel.cpp', 'src/server/server.cpp']
qt_sources = qt6.preprocess(qresources: ['src/assets/img_assets.qrc', 'src/qml.qrc'], moc_headers: ['src/helpers/station.h', 'src/helpers/keyshelper.h', 'src/helpers/commandsmodel.h', 'src/server/server.h', dbus_adaptor[1], dbus_interface[1]])
executable('station', station_sources + [dbus_adaptor, dbus_interface] + qt_sources + [station_version], dependencies: [qt, kf6_core, kf6_i18n, mauikit, terminal, filebrowsing], include_directories: station_includes, cpp_args: cpp_args, install: true)
install_data('src/org.maui.station.desktop', install_dir: get_option('datadir') / 'applications')
install_data('org.maui.station.appdata.xml', install_dir: get_option('datadir') / 'metainfo')
install_data('src/assets/station.svg', install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps')
