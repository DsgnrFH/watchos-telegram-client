// This file is part of the WatchOS Telegram Client.
// Copyright (C) 2025 DsgnrFH
// Licensed under GPL-3.0.
//
//  ZoomableImageView.swift
//  WatchosTelegram
//
//  Created by Oleksandr Barbashyn on 16.11.25.
//

import SwiftUI

struct ZoomableImageView: View {
    let image: Image
    
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var crownValue: Double
    
    var body: some View {
        GeometryReader { geo in
            image
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    DragGesture().onChanged { value in
                        offset = value.translation
                    }
                )
                .onTapGesture(count: 2) {
                    if scale > 1.0 {
                        // Zoom out on double-tap
                        withAnimation(.easeInOut) {
                            scale = 1.0
                            offset = .zero
                        }
                    } else {
                        // Zoom in on double-tap
                        withAnimation(.easeInOut) {
                            scale = 2.0
                        }
                    }
                }
                .focusable()
                .digitalCrownRotation(
                    $crownValue,
                    from: -20, through: 20, by: 0.2,
                    sensitivity: .medium,
                    isHapticFeedbackEnabled: true
                )
                .onChange(of: crownValue) { oldValue, newValue in
                    let zoom = 1.0 + CGFloat(newValue / 10.0)
                    scale = min(max(1.0, zoom), 5.0)
                }
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

