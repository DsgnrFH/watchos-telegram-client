// This file is part of the WatchOS Telegram Client.
// Copyright (C) 2025 DsgnrFH
// Licensed under GPL-3.0.
//
//  ContentView.swift
//  WatchosTelegram Watch App
//
//  Created by Oleksandr Barbashyn on 15.11.25.
//

import SwiftUI

struct ContentView: View {
    @State private var chats: [Chat] = []
    @State private var loading = true
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
            if loading {
                ProgressView("Loading...")
            } else {
                List(chats) { chat in
                    NavigationLink {
                        MessagesView(chat: chat)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(chat.name)
                                .font(.headline)
                            Text(chat.last_message ?? "")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showProfile = true
                        } label: {
                            Label("Profile", systemImage: "person.fill")
                        }
                    }
                }
                .navigationDestination(isPresented: $showProfile) {
                    ProfileView()
                }
            }
        }
        .task {
            await loadChats()
        }
    }
    
    func loadChats() async {
        do {
            chats = try await APIClient.shared.fetchChats()
        } catch {
            print("Error loading chats: ", error)
        }
        loading = false
    }
}

#Preview {
    ContentView()
}
