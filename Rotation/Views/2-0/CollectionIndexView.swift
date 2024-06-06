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
                    Text(musicEntity.title)
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
                    if let selectedEntityID, var musicEntity = musicEntities.first(where: {$0.id == selectedEntityID}) {
                        MusicEntityDetailView(musicEntity: musicEntity)
                    } else {
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
