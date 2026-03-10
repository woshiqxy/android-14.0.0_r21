/*
 * Copyright (C) 2018 The Android Open Source Project
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

package com.android.server.pm;

/**
 * Provides access to individual sessions managed by the install service as well as utilities
 * used by the install process.
 */
public interface PackageSessionProvider {

    /**
     * Get the sessions for the provided session IDs. Null will be returned for session IDs that
     * do not exist.
     * 这是最核心的方法。当安装器应用或系统其他部分需要操作一个特定的安装会话（例如写入APK数据、查询进度、提交安装）时，
     * 会通过此方法传入sessionId来获取对应的PackageInstallerSession对象。PackageInstallerSession代表了一个正在进行中的、
     * 具体的安装任务，它封装了该会话的所有状态、参数和待安装的APK文件信息。
     */
    PackageInstallerSession getSession(int sessionId);

    /**
     * 返回一个会话验证器。在安装提交前的关键时刻，系统会使用这个验证器对会话进行全面检查，包括APK文件的完整性、签名的一致性、是否与现有应用冲突等。这是保障安装安全性的重要一环。
     * @return
     */
    PackageSessionVerifier getSessionVerifier();

    /**
     * Get the GentleUpdateHelper instance.
     */
    GentleUpdateHelper getGentleUpdateHelper();
}
