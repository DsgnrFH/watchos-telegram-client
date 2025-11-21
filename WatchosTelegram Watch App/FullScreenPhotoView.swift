//
//  FullScreenPhotoView.swift
//  WatchosTelegram
//
//  Created by Oleksandr Barbashyn on 16.11.25.
//

import SwiftUI

struct FullScreenPhotoView: View, Identifiable {
    let id = UUID()
    let chatID: Int
    let messageID: Int
    
    @Environment(\.dismiss) var dismiss
    @State private var image: UIImage? = nil
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var crownValue: Double = 0
    
    var body: some View {
        ZStack {
            if let image {
                ZoomableImageView(
                    image: Image(uiImage: image),
                    scale: $scale,
                    offset: $offset,
                    crownValue: $crownValue
                )
            } else {
                ProgressView()
            }
        }
        .background(.black)
        .ignoresSafeArea()
        .onTapGesture { dismiss() }
        .task { await loadImage() }
    }
    
    func loadImage() async {
        var url = APIConfig.baseURL.appendingPathComponent("media/photo")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "chat_id", value: "\(chatID)"),
            URLQueryItem(name: "message_id", value: "\(messageID)")
        ]
        guard let finalURL = components.url else { return }
        
        var req = URLRequest(url: finalURL)
        req.addValue("Bearer \(APIConfig.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            image = UIImage(data: data)
        } catch {
            print("Full-screen image load failed:", error)
        }
    }
}

