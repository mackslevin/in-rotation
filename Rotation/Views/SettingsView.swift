//
//  SettingsView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("shouldPlayInAppleMusicApp") var shouldPlayInAppleMusicApp = true
    @AppStorage("defaultScreen") var defaultScreen = DefaultScreen.collection
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isShowingWelcomeView = false
    
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
                    Section {
                        PremiumUnlockProductView()
                            .padding()
                    }
                    
                    Section {
                        Picker("Default screen", selection: $defaultScreen) {
                            ForEach(DefaultScreen.allCases, id: \.rawValue) { screen in
                                Text(screen.rawValue.capitalized)
                                    .tag(screen)
                            }
                        }
                    }
                        
                    Section {
                        Picker("The Apple Music button should...", selection: $shouldPlayInAppleMusicApp) {
                            Text("Open in app").tag(false)
                            Text("Start playback").tag(true)
                        }
                        .listRowSpacing(0)
                        Text("For users who have an Apple Music subscription and have granted access, playback can be triggered directly from within the app.")
                            .foregroundStyle(.secondary)
                            .listRowSeparator(.hidden)
                            .font(.caption)
                            .listRowSpacing(0)
                    }
                    
                    Section {
                        Button("Show welcome screen again") {
                            isShowingWelcomeView = true
                        }
                        .fontWeight(.medium)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .sheet(isPresented: $isShowingWelcomeView, content: {
                WelcomeView(){}
            })
        }
        
    }
}

//#Preview {
//    SettingsView()
//}
