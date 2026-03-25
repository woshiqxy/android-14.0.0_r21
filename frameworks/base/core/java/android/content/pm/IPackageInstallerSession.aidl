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

import android.content.pm.Checksum;
import android.content.pm.DataLoaderParamsParcel;
import android.content.pm.IOnChecksumsReadyListener;
import android.content.pm.IPackageInstallObserver2;
import android.content.pm.PackageInstaller;
import android.content.IntentSender;
import android.os.ParcelFileDescriptor;

/** {@hide} */
interface IPackageInstallerSession {
    //设置绝对进度,下载进度明确时
    void setClientProgress(float progress);
    //增加相对进度,分段下载时
    void addClientProgress(float progress);
    //// 获取会话中的所有文件名
    String[] getNames();
    //// 打开文件进行写入（流式写入）
    ParcelFileDescriptor openWrite(String name, long offsetBytes, long lengthBytes);
    // 打开文件进行读取（用于验证）
    ParcelFileDescriptor openRead(String name);
    // 直接写入文件描述符（用于高效传输）
    void write(String name, long offsetBytes, long lengthBytes, in ParcelFileDescriptor fd);
    // 通过硬链接方式暂存（用于优化）
    void stageViaHardLink(String target);
    //校验和验证,文件完整性验证
    void setChecksums(String name, in Checksum[] checksums, in byte[] signature);
    void requestChecksums(in String name, int optional, int required, in List trustedInstallers, in IOnChecksumsReadyListener onChecksumsReadyListener);
    //拆分APK管理
    void removeSplit(String splitName);

    void close();// 关闭会话（不提交）
    void commit(in IntentSender statusReceiver, boolean forTransferred);// 提交安装
    void transfer(in String packageName);// 转移会话所有权
    void abandon();// 放弃会话
    void seal(); // 密封会话（禁止修改）
    List<String> fetchPackageNames(); // 获取包名列表

    DataLoaderParamsParcel getDataLoaderParams();//支持流式安装
    void addFile(int location, String name, long lengthBytes, in byte[] metadata, in byte[] signature);
    void removeFile(int location, String name);

    boolean isMultiPackage();// 多包会话管理
    int[] getChildSessionIds();
    void addChildSessionId(in int sessionId);
    void removeChildSessionId(in int sessionId);
    int getParentSessionId();

    boolean isStaged();//分阶段安装属性
    int getInstallFlags();// 获取安装标志

    //用户预批准,安装前预批准
    void requestUserPreapproval(in PackageInstaller.PreapprovalDetails details, in IntentSender statusReceiver);

    boolean isApplicationEnabledSettingPersistent();// 应用启用状态是否持久化
    boolean isRequestUpdateOwnership(); // 是否请求更新所有权

    ParcelFileDescriptor getAppMetadataFd();// 获取应用元数据
    ParcelFileDescriptor openWriteAppMetadata();// 打开元数据写入流
    void removeAppMetadata();// 移除元数据
}
