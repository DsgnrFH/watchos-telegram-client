# WatchosTelegram

## Overview
A lightweight watchOS Telegram client that demonstrates a custom-built API usage on Apple Watch using SwiftUI and async/await networking. The app fetches chats and messages from a simple HTTP API, supports sending text messages, displays photos (with full-screen zoom and Crown support), and plays voice messages.

> Note: This repository is a client-only. You must configure API endpoint and token to connect to your own backend that has the compatible endpoints.

## Features
- SwiftUI-first UI for watchOS
- Async/await networking with `URLSession`
- Simple models decoded from JSON
- Full-screen photo view with zoom/pan and the Crown integration via a `ZoomableImageView` (composed usage)
- Voice message playback using `AVAudioPlayer`
- Auto-refresh for new messages and a simple "load more" mechanism

This project is intentionally minimal and avoids external dependencies. Concurrency is handled with Swift Concurrency (async/await) and periodic refresh via Combine's timer publisher bridged into `.task`.

## Project Structure
- APIConfig.swift
  - Configures `baseURL` and `token` for the backend
- APIClient.swift
  - `fetchChats()`, `fetchMessages(chatID:limit:)`, `sendMessage(chatID:text:)`, `fetchMe()`
- Models.swift
  - `Chat`, `Message`, `ChatsResponse`, `MessagesResponse`
- UserIDKey.swift
  - SwiftUI environment key/value for `myUserID`
- WatchosTelegramApp.swift
  - App entry point; fetches and provides `myUserID` to the environment
- ContentView.swift
  - Displays list of chats and navigates to `MessagesView`
- MessagesView.swift
  - Displays messages grouped by day, supports send text, auto-refresh, load more, photo and voice note handling
- PhotoThumbnailView.swift
  - Loads and displays a photo thumbnail for a message
- FullScreenPhotoView.swift
  - Downloads and displays a full-resolution photo with zoom/pan and crown support
- VoicePlayerView.swift
  - Downloads a voice message and plays it with `AVAudioPlayer`

## Setup & Configuration
1) Open `APIConfig.swift` and set your backend details:
```swift:APIConfig.swift
struct APIConfig {
    static let baseURL = URL(string: "https://your.backend.address/")!
    static let token = "YOUR_TELEGRAM_TOKEN_HERE"
}
