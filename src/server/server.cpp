#include "server.h"

#include <QGuiApplication>
#include <QQuickWindow>
#include <QVariant>
#include <QQmlApplicationEngine>

#include <MauiKit4/FileBrowsing/fmstatic.h>

#include "stationinterface.h"
#include "stationadaptor.h"

QVector<QPair<QSharedPointer<OrgKdeStationActionsInterface>, QStringList>> AppInstance::appInstances(const QString& preferredService)
{
    QVector<QPair<QSharedPointer<OrgKdeStationActionsInterface>, QStringList>> dolphinInterfaces;

    if (!preferredService.isEmpty())
    {
        QSharedPointer<OrgKdeStationActionsInterface> preferredInterface(
                    new OrgKdeStationActionsInterface(preferredService,
                                                      QStringLiteral("/Actions"),
                                                      QDBusConnection::sessionBus()));

        qDebug() << "IS PREFRFRED INTERFACE VALID?" << preferredInterface->isValid() << preferredInterface->lastError().message();
        if (preferredInterface->isValid() && !preferredInterface->lastError().isValid()) {
            dolphinInterfaces.append(qMakePair(preferredInterface, QStringList()));
        }
    }

    // Look for dolphin instances among all available dbus services.
    QDBusConnectionInterface *sessionInterface = QDBusConnection::sessionBus().interface();
    const QStringList dbusServices = sessionInterface ? sessionInterface->registeredServiceNames().value() : QStringList();
    // Don't match the service without trailing "-" (unique instance)
    const QString pattern = QStringLiteral("org.kde.station-");

    // Don't match the pid without leading "-"
    const QString myPid = QLatin1Char('-') + QString::number(QCoreApplication::applicationPid());

    for (const QString& service : dbusServices)
    {
        if (service.startsWith(pattern) && !service.endsWith(myPid))
        {
            qDebug() << "EXISTING INTANCES" << service;

            // Check if instance can handle our URLs
            QSharedPointer<OrgKdeStationActionsInterface> interface(
                        new OrgKdeStationActionsInterface(service,
                                                          QStringLiteral("/Actions"),
                                                          QDBusConnection::sessionBus()));
            if (interface->isValid() && !interface->lastError().isValid())
            {
                dolphinInterfaces.append(qMakePair(interface, QStringList()));
            }
        }
    }

    return dolphinInterfaces;
}

bool AppInstance::attachToExistingInstance(const QList<QUrl>& inputUrls, bool splitView, const QString& preferredService)
{
    bool attached = false;

    auto dolphinInterfaces = appInstances(preferredService);
    if (dolphinInterfaces.isEmpty())
    {
        return false;
    }

    if(inputUrls.isEmpty())
    {
        auto interface = dolphinInterfaces.first();
        auto reply = interface.first->openNewTab("$PWD");
        reply.waitForFinished();

        if (!reply.isError())
        {
            interface.first->activateWindow();
        }

        return true;
    }

    for (const auto& interface: std::as_const(dolphinInterfaces))
    {
        auto reply = interface.first->openTabs(QUrl::toStringList(inputUrls, QUrl::PreferLocalFile), splitView);
        reply.waitForFinished();

        if (!reply.isError())
        {
            interface.first->activateWindow();
            attached = true;
            break;
        }
    }

    return attached;
}

bool AppInstance::attachCommandToExistingInstance(const QString &workingDirectory,
                                                  const QString &program,
                                                  const QStringList &arguments,
                                                  const QString &preferredService)
{
    auto interfaces = appInstances(preferredService);
    if (interfaces.isEmpty())
        return false;

    for (const auto &interface : std::as_const(interfaces)) {
        auto reply = interface.first->openCommandTab(workingDirectory, program, arguments);
        reply.waitForFinished();
        if (!reply.isError()) {
            interface.first->activateWindow();
            return true;
        }
    }

    return false;
}

bool AppInstance::registerService()
{
    QDBusConnectionInterface *iface = QDBusConnection::sessionBus().interface();

    auto registration = iface->registerService(QStringLiteral("org.kde.station-%1").arg(QCoreApplication::applicationPid()),
                                               QDBusConnectionInterface::ReplaceExistingService,
                                               QDBusConnectionInterface::DontAllowReplacement);

    if (!registration.isValid())
    {
        qWarning("2 Failed to register D-Bus service \"%s\" on session bus: \"%s\"",
                 qPrintable("org.kde.station"),
                 qPrintable(registration.error().message()));
        return false;
    }

    return true;
}

Server::Server(QObject *parent) : QObject(parent)
  , m_qmlObject(nullptr)
{
    new ActionsAdaptor(this);
    if(!QDBusConnection::sessionBus().registerObject(QStringLiteral("/Actions"), this))
    {
        qDebug() << "FAILED TO REGISTER BACKGROUND DBUS OBJECT";
        return;
    }
}

void Server::setQmlObject(QObject *object)
{
    if(!m_qmlObject)
    {
        m_qmlObject = object;
    }
}

void Server::activateWindow()
{
    if(m_qmlObject)
    {
        qDebug() << "ACTIVET WINDOW FROM C++";
        auto window = qobject_cast<QQuickWindow *>(m_qmlObject);
        if (window)
        {
            qDebug() << "Trying to raise window";
            window->raise();
            window->requestActivate();
        }
    }
}

void Server::quit()
{
    QCoreApplication::quit();
}

void Server::openTabs(const QStringList &urls, bool splitView)
{
    Q_UNUSED(splitView)

    for(const auto &url : urls)
    {
        qDebug() << "REQUEST TO OPEN TAB AT LOCATION" << url;
        this->openNewTab(url);
    }
}

void Server::openNewTab(const QString &url)
{
    if(m_qmlObject)
    {
        QMetaObject::invokeMethod(m_qmlObject, "openTab",
                                  Q_ARG(QString, url));
    }
}

void Server::openCommandTab(const QString &workingDirectory,
                            const QString &program,
                            const QStringList &arguments)
{
    if (m_qmlObject)
    {
        QMetaObject::invokeMethod(m_qmlObject, "openCommandTab",
                                  Q_ARG(QString, workingDirectory),
                                  Q_ARG(QString, program),
                                  Q_ARG(QVariant, QVariant::fromValue(arguments)));
    }
}

void Server::openNewWindow(const QString &url)
{

}
