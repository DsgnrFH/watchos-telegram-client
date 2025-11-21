//
//  WatchosTelegramApp.swift
//  WatchosTelegram Watch App
//
//  Created by Oleksandr Barbashyn on 15.11.25.
//

import SwiftUI

@main
struct WatchosTelegram_Watch_AppApp: App {
    @State private var myUserId: Int = 0

        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environment(\.myUserID, myUserId)
                    .task {
                        if let id = try? await APIClient.shared.fetchMe() {
                            myUserId = id
                        }
                    }
            }
        }
}
