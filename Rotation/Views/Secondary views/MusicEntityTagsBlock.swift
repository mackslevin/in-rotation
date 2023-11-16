//
//  MusicEntityTagsBlock.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI

struct MusicEntityTagsBlock: View {
    @Bindable var musicEntity: MusicEntity
    
    @State private var isShowingTagManager = false
    
    var body: some View {
        VStack(spacing: 12) {
            if let tags = musicEntity.tags, !tags.isEmpty {
                HStack {
                    Text("Tags")
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        isShowingTagManager = true
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
                       isShowingTagManager = true
                    } label: {
                        Label("Add Tags", systemImage: "plus.circle")
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                }
            }
            
//            Button {
//                isShowingTagManager = true
//            } label: {
//                HStack(spacing: 12) {
//                    Spacer()
//                    Text("Edit...")
//                        .fontWeight(.bold)
//                    Spacer()
//                }
//                .padding()
//                .background {
//                    RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true))
//                        .foregroundStyle(Color.secondary)
//                }
//            }
//            .tint(.primary)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false))
                .foregroundStyle(.regularMaterial)
        }
        .sheet(isPresented: $isShowingTagManager, content: {
            TagManagerView(musicEntity: musicEntity)
        })
    }
}

//#Preview {
//    MusicEntityTagsBlock(musicEntity: Utility.exampleEntity)
//}
