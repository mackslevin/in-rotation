//
//  PrimaryView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI

struct PrimaryView: View {
    @Environment(\.appleMusicAuthWrangler) var appleMusicAuthWrangler
    @State private var vm = PrimaryViewModel()
    
    var body: some View {
        TabView(selection: $vm.selectedTab) {
            CollectionIndexView()
            .tag(1)
            .tabItem { Label("Collection", systemImage: "circle.grid.3x3.fill") }
            
            TagsIndexView()
                .tag(2)
                .tabItem { Label("Tags", systemImage: "tag.fill") }
            
            ExploreView()
                .tag(3)
                .tabItem { Label("Explore", systemImage: "rectangle.portrait.on.rectangle.portrait.angled.fill") }
            
            SettingsView()
                .tag(4)
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .task {
            await appleMusicAuthWrangler.requestMusicAuth()
            await appleMusicAuthWrangler.getMusicSubscriptionUpdates()
        }
        .onAppear {
            vm.setUpAppearance()
        }
        .sheet(isPresented: $vm.shouldShowWelcomeView, content: {
            WelcomeView()
                .onDisappear {
                    vm.markWelcomeViewAsSeen()
                }
        })
    }
    
}

//#Preview {
//    
//    PrimaryView()
//        .environment(AppleMusicWrangler())
//}
