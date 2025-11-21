//
//  VoicePlayerView.swift
//  WatchosTelegram
//
//  Created by Oleksandr Barbashyn on 16.11.25.
//

//
//  VoicePlayerView.swift
//  WatchosTelegram
//

import SwiftUI
import AVFoundation

struct VoicePlayerView: View, Identifiable {
    let id = UUID()
    let chatID: Int
    let message: Message

    @Environment(\.dismiss) var dismiss
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var loading = true
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()
            
            VStack(spacing: 12) {
                if loading {
                    ProgressView()
                        .tint(.white)
                    Text("Loading…")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Button(action: togglePlay) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                            .padding(20)
                    }
                    
                    if let dur = audioPlayer?.duration {
                        Text("Duration: \(Int(dur))s")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                }
            }
        }
        .task { await loadAndPrepare() }
    }
    
    func togglePlay() {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    func loadAndPrepare() async {
        loading = true
        
        do {
            let url = try await downloadVoice()
            print("Downloaded voice URL:", url)
            
            let data = try Data(contentsOf: url)
            print("Voice file size:", data.count)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            print("Player duration: ", audioPlayer?.duration ?? -1)
            
        } catch {
            print("Voice load failed: ", error)
        }
        
        loading = false
    }
    
    func downloadVoice() async throws -> URL {
        var url = APIConfig.baseURL.appendingPathComponent("media/voice")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "chat_id", value: "\(chatID)"),
            URLQueryItem(name: "message_id", value: "\(message.id)")
        ]
        guard let finalURL = components.url else { throw URLError(.badURL) }
        
        var req = URLRequest(url: finalURL)
        req.addValue("Bearer \(APIConfig.token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: req)
        
        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("voice_\(message.id).m4a")
        
        try data.write(to: tmpURL)
        return tmpURL
    }

}
