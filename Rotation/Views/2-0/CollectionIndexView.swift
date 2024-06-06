//
//  CollectionIndexView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI
import SwiftData

struct CollectionIndexView: View {
    @Query var musicEntities: [MusicEntity]
    @State var selectedEntityID: UUID?
    
    var body: some View {
        
        
        NavigationSplitView {
            List(selection: $selectedEntityID) {
                ForEach(musicEntities) { musicEntity in
                    CollectionIndexRow(musicEntity: musicEntity)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .background { Color.customBG.ignoresSafeArea() }
            .navigationTitle("Collection")
        } detail: {
            NavigationStack {
                Group {
                    if let selectedEntityID, let musicEntity = musicEntities.first(where: {$0.id == selectedEntityID}) {
                        MusicEntityDetailView(musicEntity: musicEntity)
                    } else {
                        // TODO: Replace with something custom, including custom font
                        ContentUnavailableView("Nothing Selected", systemImage: "questionmark.app.dashed")
                    }
                }
                .background { Color.customBG.ignoresSafeArea() }
                
            }
        }

    }
}

#Preview {
    PrimaryView()
//    CollectionIndexView()
}
