// This file is part of the WatchOS Telegram Client.
// Copyright (C) 2025 DsgnrFH
// Licensed under GPL-3.0.
//
//  Models.swift
//  WatchosTelegram
//
//  Created by Oleksandr Barbashyn on 16.11.25.
//

import Foundation

struct Chat: Codable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let last_message: String?
}


struct Message: Codable, Identifiable {
    let id: Int
    let sender_id: Int?
    let date: String
    let text: String?
    let has_photo: Bool
    let has_document: Bool
    let mime_type: String?
}
extension Message {
    var dateOnly: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: date) ?? Date()
    }
}


struct ChatsResponse: Codable {
    let chats: [Chat]
}

struct MessagesResponse: Codable {
    let messages: [Message]
}
