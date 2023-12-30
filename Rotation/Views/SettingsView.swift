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
    
    @State private var isShowingWelcomView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Settings")
                        .font(.displayFont(ofSize: 32))
                        .foregroundStyle(.accent)
                    Spacer()
                }
                .padding()
                
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
                    
                    Section {
                        Button("Show welcome screen again") {
                            isShowingWelcomView = true
                        }
                        .fontWeight(.medium)
                    }
                    
                    Section("In-App Purchase") {
                        PremiumUnlockProductView()
                            .padding()
                    }
                }
                .scrollContentBackground(.hidden)
            }
            
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .sheet(isPresented: $isShowingWelcomView, content: {
                WelcomeView(){}
            })
        }
        
    }
}

#Preview {
    SettingsView()
}
