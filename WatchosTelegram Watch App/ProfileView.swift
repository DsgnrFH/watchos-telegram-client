// This file is part of the WatchOS Telegram Client.
// Copyright (C) 2025 DsgnrFH
// Licensed under GPL-3.0.

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            
            HStack {
                Spacer()
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.tint)
                Spacer()
            }
            List {
                
                Text("@username")
                    .font(.headline)
                Text("Display name")
                    .font(.caption2)
            }
            
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    ProfileView()
}
