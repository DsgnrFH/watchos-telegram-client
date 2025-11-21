//
//  APIClient.swift
//  WatchosTelegram
//
//  Created by Oleksandr Barbashyn on 16.11.25.
//

import Foundation

final class APIClient {
    static let shared = APIClient()
    
    private let session = URLSession.shared
    
    private func makeRequest(path: String, query: [String: String]? = nil) -> URLRequest {
        var url = APIConfig.baseURL.appendingPathComponent(path)
        
        if let query = query {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
            url = components.url!
        }
        
        var req = URLRequest(url: url)
        req.addValue("Bearer \(APIConfig.token)", forHTTPHeaderField: "Authorization")
        return req
    }
    
    // MARK: Chats
    func fetchChats() async throws -> [Chat] {
        let req = makeRequest(path: "chats")
        let (data, _) = try await session.data(for: req)
        let wrapper = try JSONDecoder().decode(ChatsResponse.self, from: data)
        return wrapper.chats
    }
    
    // MARK: Messages
    func fetchMessages(chatID: Int, limit: Int = 20) async throws -> [Message] {
        let req = makeRequest(
            path: "messages",
            query: ["chat_id": "\(chatID)", "limit": "\(limit)"]
        )
        let (data, _) = try await session.data(for: req)
        let wrapper = try JSONDecoder().decode(MessagesResponse.self, from: data)
        return wrapper.messages
    }
    
    // MARK: Send text message
    func sendMessage(chatID: Int, text: String) async throws {
        var req = makeRequest(path: "send_message")
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "chat_id": chatID,
            "text": text
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        _ = try await session.data(for: req)
    }
    
    // MARK: Check whether a message is sent by me
    func fetchMe() async throws -> Int {
        let req = makeRequest(path: "me")
        let (data, _) = try await session.data(for: req)
        let obj = try JSONDecoder().decode([String: Int].self, from: data)
        return obj["me_id"]!
    }

}
