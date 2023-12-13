//
//  HomeView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var selectedTab = 1
    
//    @State private var appleMusicAuthWrangler = AppleMusicAuthWrangler()
    @Environment(\.appleMusicAuthWrangler) var appleMusicAuthWrangler
    @AppStorage("defaultScreen") var defaultScreen = DefaultScreen.collection
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CollectionView()
                .tag(1)
                .tabItem { Label("Collection", systemImage: "circle.grid.3x3.fill") }
            
            TagsView()
                .tag(2)
                .tabItem { Label("Tags", systemImage: "tag.fill") }
            
            ExploreView()
                .tag(3)
                .tabItem { Label("Explore", systemImage: "rectangle.on.rectangle.angled") }
            
            SettingsView()
                .tag(4)
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .task {
            await appleMusicAuthWrangler.requestMusicAuth()
            await appleMusicAuthWrangler.getMusicSubscriptionUpdates()
        }
        .onAppear {
            switch defaultScreen {
                case .collection:
                    selectedTab = 1
                case .tags:
                    selectedTab = 2
                case .explore:
                    selectedTab = 3
            }
        }
    }
}

#Preview {
    HomeView()
}
