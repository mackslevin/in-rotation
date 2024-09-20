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
    @State private var tabViewStyle: any TabViewStyle = DefaultTabViewStyle()
    
    
    var body: some View {
        
        
        TabView(selection: $vm.selectedTab) {
            
            Tab("Collection", systemImage: "circle.grid.3x3" , value: 1) {
                CollectionIndexView()
            }
            
            Tab("Tags", systemImage: "tag" , value: 2) {
                TagsIndexView()
            }
            
            Tab("Explore", systemImage: "rectangle.portrait.on.rectangle.portrait.angled" , value: 3) {
                ExploreView()
            }
            
            Tab("Settings", systemImage: "gear" , value: 4) {
                SettingsView()
            }
            
        }
        .tabViewStyle(.tabBarOnly)
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
