// This file is part of the WatchOS Telegram Client.
// Copyright (C) 2025 DsgnrFH
// Licensed under GPL-3.0.
//
//  UserIDKey.swift
//  WatchosTelegram
//
//  Created by Oleksandr Barbashyn on 16.11.25.
//

import SwiftUI

struct UserIDKey: EnvironmentKey {
    static let defaultValue: Int = 0
}

extension EnvironmentValues {
    var myUserID: Int {
        get { self[UserIDKey.self] }
        set { self[UserIDKey.self] = newValue }
    }
}
