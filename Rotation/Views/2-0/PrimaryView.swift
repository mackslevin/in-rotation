//
//  PrimaryView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI

struct PrimaryView: View {
    @State private var selectedTab = 1
    @Environment(\.appleMusicAuthWrangler) var appleMusicAuthWrangler
    @AppStorage("defaultScreen") var defaultScreen = DefaultScreen.collection
    
//    @AppStorage("shouldShowWelcomeView") var shouldShowWelcomeView = true
    @AppStorage("shouldShowWelcomeView") var shouldShowWelcomeView = false // TODO: Change back
    
    @State private var vm = PrimaryViewModel()
    
    var body: some View {
        if shouldShowWelcomeView {
            WelcomeView() {
                withAnimation {
                    shouldShowWelcomeView = false
                }
            }
        } else {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    List {
                        Text("Hello")
                            .listRowSeparator(.hidden)
                    }
                    .navigationTitle("Collection")
                    .listRowBackground(Color.clear)
                    .listStyle(.plain)
                        
                }
                
                .tag(1)
                .tabItem { Label("Collection", systemImage: "circle.grid.3x3.fill") }
                    
                
                Text("Tags")
                    .tag(2)
                    .tabItem { Label("Tags", systemImage: "tag.fill") }
                
                Text("Explore")
                    .tag(3)
                    .tabItem { Label("Explore", systemImage: "rectangle.on.rectangle.angled") }
                
                Text("Settings")
                    .tag(4)
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
            .task {
                await appleMusicAuthWrangler.requestMusicAuth()
                await appleMusicAuthWrangler.getMusicSubscriptionUpdates()
            }
            .onAppear {
                // Set default tab
                switch defaultScreen {
                    case .collection:
                        selectedTab = 1
                    case .tags:
                        selectedTab = 2
                    case .explore:
                        selectedTab = 3
                }
                
                // Customize appearance
                UINavigationBar.appearance().largeTitleTextAttributes = [
                    .font: UIFont(name: "PPPierSans-Bold", size: 48)!
                ]
                UINavigationBar.appearance().titleTextAttributes = [
                    .font: UIFont(name: "PPPierSans-Bold", size: 20)!
                ]
                
                UITabBar.appearance().backgroundColor = UIColor(Color.customBG)
                UITabBar.appearance().unselectedItemTintColor = UIColor(Color.accentColor.opacity(0.5))
            }
            
            
        }
    }
}

#Preview {
    PrimaryView()
}
