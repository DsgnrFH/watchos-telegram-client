//
//  UserColor.swift
//  WatchosTelegram
//
//  Created by Oleksandr Barbashyn on 16.11.25.
//

import SwiftUI

let userColors: [Color] = [
    .red, .orange, .yellow, .green, .mint,
    .teal, .cyan, .blue, .indigo, .purple,
    .pink, .brown
]

func colorForUser(_ userId: Int?) -> Color {
    guard let userId else { return .gray }

    let index = abs(userId.hashValue) % userColors.count
    return userColors[index]
}
