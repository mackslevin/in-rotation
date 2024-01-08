//
//  TagMusicEntitiesListingView.swift
//  Rotation
//
//  Created by Mack Slevin on 1/8/24.
//

import SwiftUI
import SwiftData

struct TagMusicEntitiesListingView: View {
    @Bindable var tag: Tag
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.horizontalSizeClass) var horizontalSize
    @Environment(\.dismiss) var dismiss
    
    @State private var columnCount = 2
    
    @Binding var selectedMusicEntity: MusicEntity?
    
    var body: some View {

        
        
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: columnCount), alignment: .center, spacing: 5) {
                    
                    ForEach(tag.musicEntities!) { musicEntity in
                        Button(musicEntity.title) {
                            selectedMusicEntity = musicEntity
                        }
                    }
                    
                }
            }
            .onAppear {
                if horizontalSize == .regular {
                    columnCount = 3
                } else {
                    columnCount = 2
                }
            }
            .onChange(of: horizontalSize) { _, newValue in
                if newValue == .regular {
                    columnCount = 3
                } else {
                    columnCount = 2
                }
            }
            
        
        
        
    }
}

//#Preview {
//    TagMusicEntitiesListingView()
//}
