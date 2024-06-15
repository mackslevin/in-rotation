//
//  MusicEntityDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI
import SwiftData

struct MusicEntityDetailView: View {
    @Bindable var musicEntity: MusicEntity
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack() {
                    
                    LazyVGrid(columns: 
                                horizontalSize == .compact ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())], content: {
                        
                        if musicEntity.imageData != nil {
                            musicEntity.image.resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(maxWidth: 400, maxHeight: 400)
                                .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                        }
                        
                        MusicEntityHeadlineBlock(musicEntity: musicEntity)
                    })
                    
                    
                    
                }
                .padding()
                
                
            }
            .navigationTitle(musicEntity.title)
            .navigationBarTitleDisplayMode(.inline)
            .background {
                ZStack {
                    musicEntity.image.resizable().scaledToFill()
                    Rectangle()
                        .foregroundStyle(.thinMaterial)
                }
                .ignoresSafeArea()
            }
        }
        
        
    }
}

#Preview {
    MusicEntityDetailView(musicEntity: Utility.exampleEntity)
}
