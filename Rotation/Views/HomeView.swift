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
        
    }
}

#Preview {
    HomeView()
}
