/*
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package android.content.pm;

import android.content.pm.IPackageDeleteObserver2;
import android.content.pm.IPackageInstallerCallback;
import android.content.pm.IPackageInstallerSession;
import android.content.pm.PackageInstaller;
import android.content.pm.ParceledListSlice;
import android.content.pm.VersionedPackage;
import android.content.IntentSender;
import android.os.RemoteCallback;

import android.graphics.Bitmap;

/** {@hide} */
interface IPackageInstaller {

    /**
    * 作用：创建新的安装会话
    * params：会话参数，包括安装模式、APK大小、是否拆分APK等
    * installerPackageName：安装器包名（用于权限检查）
    * installerAttributionTag：归因标签（Android 10+，用于隐私增强）
    * userId：目标用户
    * 返回:新创建的 Session ID
    */
    int createSession(in PackageInstaller.SessionParams params, String installerPackageName,
            String installerAttributionTag, int userId);

    /**
    * 会话元数据更新
    * 更新会话中待安装应用的图标和标签
    * 在安装过程中，系统UI可以显示应用的图标和名称，即使APK尚未完全下载
    **/
    void updateSessionAppIcon(int sessionId, in Bitmap appIcon);
    void updateSessionAppLabel(int sessionId, String appLabel);

    /**
    * 放弃一个未完成的会话
    * 触发场景：用户取消安装、下载失败等
    */
    void abandonSession(int sessionId);

    /**
    * 会话访问与数据写入,获取会话的数据写入通道
    * 后续操作：通过返回的接口，调用者可以：openWrite()：打开文件流,write()：写入APK数据,commit()：提交安装（最终触发PMS）
    **/
    IPackageInstallerSession openSession(int sessionId);

    //获取单个会话的详细信息（进度、状态等）
    PackageInstaller.SessionInfo getSessionInfo(int sessionId);
    //获取系统中所有活跃会话（需要系统权限）
    ParceledListSlice getAllSessions(int userId);
    //获取特定安装器创建的所有会话
    ParceledListSlice getMySessions(String installerPackageName, int userId);
    //获取等待重启的会话（用于OTA或APEX更新）
    ParceledListSlice getStagedSessions();

    //安装器应用注册回调，接收安装进度、成功/失败等通知.回调方法包括：onSessionCreated()、onSessionProgressChanged()、onSessionFinished() 等
    void registerCallback(IPackageInstallerCallback callback, int userId);
    void unregisterCallback(IPackageInstallerCallback callback);

    //卸载应用,注意：这个方法虽然在这里，但实际卸载流程会经过 PackageManagerService,@UnsupportedAppUsage 注解表示非SDK接口限制
    @UnsupportedAppUsage(maxTargetSdk = 30, trackingBug = 170729553)
    void uninstall(in VersionedPackage versionedPackage, String callerPackageName, int flags,
            in IntentSender statusReceiver, int userId);

    void uninstallExistingPackage(in VersionedPackage versionedPackage, String callerPackageName,
            in IntentSender statusReceiver, int userId);

    void installExistingPackage(String packageName, int installFlags, int installReason,
            in IntentSender statusReceiver, int userId, in List<String> whiteListedPermissions);

    //安装过程中，系统弹出权限确认对话框后，用户的选择结果. 系统UI显示权限请求 -> 用户确认 -> 调用此方法通知服务
    void setPermissionsResult(int sessionId, boolean accepted);

    void bypassNextStagedInstallerCheck(boolean value);

    void bypassNextAllowedApexUpdateCheck(boolean value);

    void disableVerificationForUid(int uid);

    void setAllowUnlimitedSilentUpdates(String installerPackageName);
    void setSilentUpdatesThrottleTime(long throttleTimeInSeconds);
    //检查当前是否满足安装约束条件（如应用不在前台运行）
    void checkInstallConstraints(String installerPackageName, in List<String> packageNames,
            in PackageInstaller.InstallConstraints constraints, in RemoteCallback callback);
    //等待直到约束条件满足，或超时. 用途：实现"温和更新"，避免打扰用户
    void waitForInstallConstraints(String installerPackageName, in List<String> packageNames,
            in PackageInstaller.InstallConstraints constraints, in IntentSender callback,
            long timeout);
}
