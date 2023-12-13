//
//  SettingsView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("shouldPlayInAppleMusicApp") var shouldPlayInAppleMusicApp = false
    @AppStorage("defaultScreen") var defaultScreen = DefaultScreen.collection
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Defaults") {
                    Picker("Default screen", selection: $defaultScreen) {
                        ForEach(DefaultScreen.allCases, id: \.rawValue) { screen in
                            Text(screen.rawValue.capitalized)
                                .tag(screen)
                        }
                    }
                    
                    Picker("The Apple Music button should...", selection: $shouldPlayInAppleMusicApp) {
                        Text("Open in app").tag(false)
                        Text("Start playback").tag(true)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
        }
        
    }
}

#Preview {
    SettingsView()
}
