//
//  RemoteManager.swift
//  SmartCleaner
//
//  Created by Max Khizhniakov on 28.08.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

class RemoteManager {
    // MARK: - Methods
    static func remoteConfig() -> RemoteConfig {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        return remoteConfig
    }
}
