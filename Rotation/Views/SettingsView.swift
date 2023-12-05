//
//  SettingsView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("shouldPlayInAppleMusicApp") var shouldPlayInAppleMusicApp = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Apple Music") {
                    Picker("The Apple Music Button Should...", selection: $shouldPlayInAppleMusicApp) {
                        Text("Open in app").tag(false)
                        Text("Start playback").tag(true)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingsView()
}
