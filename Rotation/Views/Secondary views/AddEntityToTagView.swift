//
//  AddEntityToTagView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/26/24.
//

import SwiftUI
import SwiftData

struct AddEntityToTagView: View {
    @Bindable var tag: Tag
    @Environment(\.dismiss) var dismiss
    @Query var allEntities: [MusicEntity]
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: horizontalSize == .compact ? 1 : 2)
                ) {
                    ForEach(allEntities.sorted(by: {$0.title > $1.title})) { musicEntity in
                        Button {
                            toggleMusicEntityInclusion(musicEntity)
                        } label: {
                            HStack {
                                musicEntity.image.resizable().scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                                VStack(alignment: .leading) {
                                    Text(musicEntity.title)
                                    Text(musicEntity.artistName)
                                        .font(.caption)
                                }
                                .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Image(systemName: (tag.musicEntities ?? []).contains(musicEntity) ? "checkmark.circle.fill" : "circle")
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true))
                                .foregroundStyle(.thinMaterial)
                        }
                        
                    }
                    
                }
                
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            .ignoresSafeArea(edges: .bottom)
            .background { Color.customBG.ignoresSafeArea() }
            .navigationTitle(tag.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
            
            
            
        }
        
    }
    
    func toggleMusicEntityInclusion(_ musicEntity: MusicEntity) {
        withAnimation {
            if (tag.musicEntities ?? []).contains(musicEntity) {
                tag.musicEntities?.removeAll(where: {$0.id == musicEntity.id})
                musicEntity.tags?.removeAll(where: {$0.id == tag.id})
            } else {
                tag.musicEntities?.append(musicEntity)
                musicEntity.tags?.append(tag)
            }
        }
    }
}

//#Preview {
//    AddEntityToTagView(tag: .constant(Utility.exampleTag))
//}
