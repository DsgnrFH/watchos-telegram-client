//
//  PhotoThumbnailView.swift
//  WatchosTelegram
//
//  Created by Oleksandr Barbashyn on 16.11.25.
//

import SwiftUI

struct PhotoThumbnailView: View {
    let chatID: Int
    let messageID: Int
    @State private var image: Image? = nil
    
    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                ProgressView()
                    .frame(width: 60, height: 60)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    func loadImage() async {
        var url = APIConfig.baseURL.appendingPathComponent("media/photo")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "chat_id", value: "\(chatID)"),
            URLQueryItem(name: "message_id", value: "\(messageID)")
        ]
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(APIConfig.token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let uiImg = UIImage(data: data) {
                image = Image(uiImage: uiImg)
            }
        } catch {
            print("Thumbnail load failed: ", error)
        }
    }
}

