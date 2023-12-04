//
//  MusicEntityTagsBlock.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI

struct MusicEntityTagsBlock: View {
    @Bindable var musicEntity: MusicEntity
    
    @State private var isShowingTagToggler = false
    
    @State private var newTags: [Tag] = []
    
    var body: some View {
        VStack(spacing: 12) {
            if let tags = musicEntity.tags, !tags.isEmpty {
                HStack {
                    Text("Tags")
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        isShowingTagToggler = true
                    } label: {
                        Image(systemName: "minus.forwardslash.plus")
                    }
                }
                
                ForEach(tags) { tag in
                    NavigationLink {
                        TagDetailView(tag: tag)
                    } label: {
                        HStack(spacing: 12) {
                            Spacer()
                            Image(systemName: tag.symbolName)
                            Text(tag.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true))
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .tint(.primary)
                }
            } else {
                HStack {
                    Spacer()
                    Button {
                       isShowingTagToggler = true
                    } label: {
                        Label("Add Tags", systemImage: "plus.circle")
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false))
                .foregroundStyle(.regularMaterial)
        }
        .onAppear {
            if let existingTags = musicEntity.tags {
                newTags = existingTags
            }
        }
        .onChange(of: newTags, { _, newValue in
            musicEntity.tags = newValue
        })
        .sheet(isPresented: $isShowingTagToggler, content: {
            TagTogglerView(selectedTags: $newTags)
        })
    }
}

//#Preview {
//    MusicEntityTagsBlock(musicEntity: Utility.exampleEntity)
//}
