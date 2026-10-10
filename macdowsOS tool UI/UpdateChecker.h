#pragma once

#include <QtCore/QDateTime>
#include <QtCore/QJsonDocument>
#include <QtCore/QJsonObject>
#include <QtCore/QObject>
#include <QtCore/QPointer>
#include <QtCore/QRegularExpression>
#include <QtCore/QString>
#include <QtCore/QUrl>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkRequest>

#include "All.h"

// GitHub Releases 更新检查接口。
// 只负责获取版本信息，不负责安装更新；下载/安装可在上层根据 releaseUrl 实现。
class UpdateChecker : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentVersion READ currentVersion CONSTANT)
    Q_PROPERTY(QString currentTag READ currentTag CONSTANT)
    Q_PROPERTY(QString updateState READ updateState NOTIFY updateStateChanged)
    Q_PROPERTY(bool updateAvailable READ updateAvailable NOTIFY updateAvailableChanged)
    Q_PROPERTY(QString latestVersion READ latestVersion NOTIFY latestVersionChanged)
    Q_PROPERTY(QString releaseUrl READ releaseUrl NOTIFY releaseUrlChanged)
    Q_PROPERTY(QString lastCheckedText READ lastCheckedText NOTIFY lastCheckedTextChanged)
    Q_PROPERTY(QString updateMessage READ updateMessage NOTIFY updateMessageChanged)

public:
    explicit UpdateChecker(QObject* parent = nullptr) : QObject(parent) {
        connect(&m_networkManager, &QNetworkAccessManager::finished, this,
                &UpdateChecker::onReplyFinished);
    }

    QString currentVersion() const {
        return QString::fromLatin1(MacdowsOSBuild::kVersionName);
    }
    QString currentTag() const {
        return QString::fromLatin1(MacdowsOSBuild::kVersionTag);
    }
    QString updateState() const { return m_updateState; }
    bool updateAvailable() const { return m_updateAvailable; }
    QString latestVersion() const { return m_latestVersion; }
    QString releaseUrl() const { return m_releaseUrl; }
    QString lastCheckedText() const { return m_lastCheckedText; }
    QString updateMessage() const { return m_updateMessage; }

    // 状态：idle / checking / available / up-to-date / error。
    Q_INVOKABLE void checkForUpdates() {
        if (m_reply) {
            m_reply->abort();
            m_reply->deleteLater();
            m_reply = nullptr;
        }

        m_updateState = QStringLiteral("checking");
        m_updateAvailable = false;
        m_updateMessage = QStringLiteral("正在连接 GitHub 获取最新版本…");
        emit updateStateChanged();
        emit updateAvailableChanged();
        emit updateMessageChanged();

        QNetworkRequest request(QUrl(QStringLiteral(
            "https://api.github.com/repos/aiboqiao6/macdowsOS-Tool/releases/latest")));
        request.setHeader(QNetworkRequest::UserAgentHeader,
                          QStringLiteral("macdowsOS-Tool/%1").arg(currentVersion()));
        request.setRawHeader("Accept", "application/vnd.github+json");
        m_reply = m_networkManager.get(request);
    }

signals:
    void updateStateChanged();
    void updateAvailableChanged();
    void latestVersionChanged();
    void releaseUrlChanged();
    void lastCheckedTextChanged();
    void updateMessageChanged();

private:
    static bool isNewerVersion(const QString& remoteTag,
                               const QString& localTag) {
        if (remoteTag.size() < 8 || localTag.size() < 8)
            return false;

        const QString remoteNumber = remoteTag.left(8);
        const QString localNumber = localTag.left(8);
        static const QRegularExpression eightDigits(
            QStringLiteral("^\\d{8}$"));
        if (!eightDigits.match(remoteNumber).hasMatch() ||
            !eightDigits.match(localNumber).hasMatch()) {
            return false;
        }

        bool remoteOk = false;
        bool localOk = false;
        const quint64 remoteValue = remoteNumber.toULongLong(&remoteOk);
        const quint64 localValue = localNumber.toULongLong(&localOk);
        return remoteOk && localOk && remoteValue > localValue;
    }

    void onReplyFinished(QNetworkReply* reply) {
        if (reply != m_reply)
            return;
        m_reply = nullptr;
        reply->deleteLater();

        m_lastCheckedText = QDateTime::currentDateTime().toString(
            QStringLiteral("yyyy年M月d日 HH:mm"));
        emit lastCheckedTextChanged();

        if (reply->error() != QNetworkReply::NoError) {
            m_updateState = QStringLiteral("error");
            m_updateMessage = QStringLiteral("暂时无法连接更新服务，请稍后重试。");
            emit updateStateChanged();
            emit updateMessageChanged();
            return;
        }

        const QJsonObject release = QJsonDocument::fromJson(reply->readAll()).object();
        const QString version = release.value(QStringLiteral("tag_name")).toString();
        const QString url = release.value(QStringLiteral("html_url")).toString();
        if (version.isEmpty() || url.isEmpty()) {
            m_updateState = QStringLiteral("error");
            m_updateMessage = QStringLiteral("更新信息格式不完整，请前往官方发布页查看。");
            emit updateStateChanged();
            emit updateMessageChanged();
            return;
        }

        m_latestVersion = version;
        m_releaseUrl = url;
        m_updateAvailable = isNewerVersion(
            version, currentTag());
        m_updateState = m_updateAvailable ? QStringLiteral("available")
                                           : QStringLiteral("up-to-date");
        m_updateMessage = m_updateAvailable
            ? QStringLiteral("发现新版本，建议从官方发布页下载安装。")
            : QStringLiteral("你正在使用最新版本。");
        emit latestVersionChanged();
        emit releaseUrlChanged();
        emit updateAvailableChanged();
        emit updateStateChanged();
        emit updateMessageChanged();
    }

    QNetworkAccessManager m_networkManager;
    QPointer<QNetworkReply> m_reply;
    QString m_updateState{QStringLiteral("idle")};
    bool m_updateAvailable = false;
    QString m_latestVersion;
    QString m_releaseUrl{QStringLiteral(
        "https://github.com/aiboqiao6/macdowsOS-Tool/releases")};
    QString m_lastCheckedText;
    QString m_updateMessage{QStringLiteral("检查 GitHub Releases，获取最新版本信息。")};
};
