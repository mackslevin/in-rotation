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
            
            
            Text("Tags")
                .tag(2)
                .tabItem { Label("Tags", systemImage: "tag.fill") }
                .background { Color.customBG.ignoresSafeArea() }
            
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

#Preview {
    PrimaryView()
}
