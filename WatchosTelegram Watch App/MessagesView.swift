//
//  MessagesView.swift
//  WatchosTelegram
//
//  Created by Oleksandr Barbashyn on 16.11.25.
//

import SwiftUI
import Combine

struct MessagesView: View {
    let chat: Chat
    
    @Environment(\.myUserID) var myUserID
    
    private struct SelectedPhoto: Identifiable, Equatable {
        let chatID: Int
        let messageID: Int
        var id: String { "\(chatID)-\(messageID)" }
    }
    
    @State private var messages: [Message] = []
    @State private var loading = true
    @State private var newMessage = ""
    @State private var loadedCount = 20
    @State private var selectedPhoto: SelectedPhoto? = nil
    @State private var showRelativeTime = false
    
    @State private var selectedRecorder: Bool = false

    @State private var selectedVoice: Message? = nil
    
    @State private var scrollProxy: ScrollViewProxy?
    
    struct MessageSection {
        let label: String
        let messages: [Message]
    }

    var groupedMessages: [(label: String, messages: [Message])] {
        // Pre-sort messages once (newest first)
        let sorted = messages.sorted { $0.id > $1.id }

        // Group by day label
        var buckets: [String: [Message]] = [:]
        let calendar = Calendar.current
        for msg in sorted { // This helps the type checker
            let day = calendar.startOfDay(for: msg.dateOnly)
            let key = dateLabel(for: day)
            buckets[key, default: []].append(msg)
        }

        var sections: [(label: String, messages: [Message])] = []
        for (key, value) in buckets {
            sections.append((label: key, messages: value))
        }

        // Sort sections by the newest message date
        sections.sort { lhs, rhs in
            let lDate = lhs.messages.first?.dateOnly ?? .distantPast
            let rDate = rhs.messages.first?.dateOnly ?? .distantPast
            return lDate > rDate
        }

        return sections
    }

    @ViewBuilder
    private func messagesList(proxy: ScrollViewProxy) -> some View {
        List {
            ForEach(groupedMessages, id: \.label) { section in
                Section(header:
                            Text(section.label)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                ) {
                    ForEach(section.messages) { msg in
                        HStack {
                            if msg.sender_id == myUserID {
                                Spacer(minLength: 20)
                                messageBubble(msg, isMe: true)
                            } else {
                                messageBubble(msg, isMe: false)
                                Spacer(minLength: 20)
                            }
                        }
                        .id(msg.id)
                    }
                }
            }
        }
    }

    var body: some View {
        VStack {
            if loading {
                ProgressView()
            } else {
                ScrollViewReader { proxy in
                    messagesList(proxy: proxy)
                    .onAppear {
                        scrollProxy = proxy
                    }
                    .onChange(of: messages.count) { oldValue, newValue in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .fullScreenCover(item: $selectedPhoto) { selected in
                    FullScreenPhotoView(chatID: selected.chatID, messageID: selected.messageID)
                }
                .fullScreenCover(item: $selectedVoice) { msg in
                    VoicePlayerView(chatID: chat.id, message: msg)
                }

            }
            
            HStack {
                TextField("Text", text: $newMessage)
                    .frame(height: 30)
                
                Button("Send") {
                    Task {
                        await sendText()
                    }
                }

            }
        }
        .navigationTitle(chat.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await loadMoreToolbar() }
                } label: {
                    Image(systemName: "arrow.down.circle")
                        .font(.title3)
                }
            }
        }

        .task {
            await loadMessages()
        }
        .task {
            // Auto-refresh every 5 seconds
            for await _ in Timer.publish(every: 5, on: .main, in: .common).autoconnect().values {
                await refreshMessagesAutoscroll()
            }
        }
        .task {
            for await _ in Timer.publish(every: 5, on: .main, in: .common).autoconnect().values {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showRelativeTime.toggle()
                }
            }
        }

    }
    
    
    func loadMessages() async {
        do {
            messages = try await APIClient.shared.fetchMessages(chatID: chat.id, limit: loadedCount)
            messages = messages.sorted { $0.id > $1.id }
        } catch {
            print("Error loading messages: ", error)
        }
        loading = false
    }
    
    func sendText() async {
        guard !newMessage.isEmpty else { return }
        
        do {
            try await APIClient.shared.sendMessage(chatID: chat.id, text: newMessage)
            newMessage = ""
            await loadMessages()
        } catch {
            print("Send failed: ", error)
        }
    }
    
    func refreshMessagesAutoscroll() async {
        do {
            let newMessages = try await APIClient.shared.fetchMessages(chatID: chat.id, limit: loadedCount)
            
            let oldLast = messages.last?.id ?? -1
            let newLast = newMessages.last?.id ?? -1
            if newLast != oldLast {
                messages = newMessages.sorted { $0.id > $1.id }
            }
            
        } catch {
            print("Auto-refresh failed: ", error)
        }
    }
    
    func loadMoreToolbar() async {
        guard !loading else { return }
        loading = true

        // Capture first visible message
        let firstVisibleID = messages.first?.id

        loadedCount += 20

        do {
            let newMessages = try await APIClient.shared.fetchMessages(
                chatID: chat.id,
                limit: loadedCount
            )
            messages = newMessages.sorted { $0.id > $1.id }
        } catch {
            print("Load more failed: ", error)
        }

        loading = false

        // Restore scroll position (breaks sometiems)
        if let firstVisibleID {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation {
                    scrollProxy?.scrollTo(firstVisibleID, anchor: .top)
                }
            }
        }
    }

    
    @ViewBuilder
    func messageBubble(_ msg: Message, isMe: Bool) -> some View {
        VStack(alignment: isMe ? .trailing : .leading, spacing: 2) {
            if let text = msg.text {
                Text(text)
                    .foregroundColor(isMe ? .indigo : .primary)
                    .multilineTextAlignment(isMe ? .trailing : .leading)
                
                if msg.has_photo {
                    Button {
                        // trigger fullscreen mode
                        selectedPhoto = SelectedPhoto(chatID: chat.id, messageID: msg.id)
                    } label: {
                        PhotoThumbnailView(chatID: chat.id, messageID: msg.id)
                    }
                    .buttonStyle(.plain)
                }
                
                else if msg.mime_type == "audio/ogg" {
                    Button {
                        selectedVoice = msg
                    } label: {
                        HStack {
                            Image(systemName: "play.circle")
                                .font(.title2)
                            Text("Voice message")
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                else if msg.has_document {
                    Text("[Media]")
                        .foregroundColor(isMe ? .indigo : .primary)
                }
            }
            
            ZStack {
                Text(showRelativeTime ? relativeTime(msg.date) : formattedTime(msg.date))
                    .font(.caption2)
                    .foregroundColor(colorForUser(msg.sender_id))
                    .frame(maxWidth: .infinity, alignment: isMe ? .trailing : .leading)
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 4)
    }


    func formattedTime(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return "" }

        let out = DateFormatter()
        out.dateFormat = "HH:mm"
        return out.string(from: date)
    }

    func relativeTime(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return "" }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .abbreviated
        return rel.localizedString(for: date, relativeTo: Date())
    }

}
