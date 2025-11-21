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
