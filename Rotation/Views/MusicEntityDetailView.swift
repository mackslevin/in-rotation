//
//  MusicEntityDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI

struct MusicEntityDetailView: View {
    @Bindable var musicEntity: MusicEntity
    @State private var amWrangler = AppleMusicWrangler()
    @State private var isShowingErrorAlert = false
    @State private var spotifyWrangler = SpotifyAPIWrangler()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        if musicEntity.imageData != nil { // We're not gonna show the placeholder image
                            musicEntity.image.resizable().scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                                .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15) , radius: 5, x: 1, y: 5)
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(musicEntity.title)
                                    .font(.displayFont(ofSize: 28))
                                    
                                HStack(alignment: .bottom) {
                                    Text("by \(musicEntity.artistName)")
                                        .font(.displayFont(ofSize: 20))
                                        .multilineTextAlignment(.leading)
                                    
                                    if let tags = musicEntity.tags, !tags.isEmpty {
                                        
                                        Spacer()
                                        Group {
                                            let last = tags.count < 4 ? tags.count - 1 : 3
                                            
                                            ForEach(tags[0...last]) { tag in
                                                Image(systemName: tag.symbolName)
                                                    .font(.caption)
                                            }
                                            
                                            if tags.count > 4 {
                                                let howManyMoreTags = tags.count - 4
                                                Text("+\(howManyMoreTags)")
                                                    .font(.caption)
                                            }
                                        }
                                        .foregroundStyle(.secondary)
                                    } else {
                                        Spacer()
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    
                    MusicEntityActionBlock(musicEntity: musicEntity, isShowingErrorAlert: $isShowingErrorAlert)
                    MusicEntityDetailsBlock(musicEntity: musicEntity)
                    MusicEntityTagsBlock(musicEntity: musicEntity)
                    MusicEntityNotesBlock(musicEntity: musicEntity)
                }
                .padding([.horizontal, .bottom])
                
                
            }
            .background {
                ZStack {
                    musicEntity.image.resizable().scaledToFill()
                    Rectangle()
                        .foregroundStyle(.regularMaterial)
                }
                .ignoresSafeArea()
            }
            .navigationTitle(Utility.stringForType(musicEntity.type))
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowingErrorAlert, content: {
                Alert(title: Text("Something went wrong"))
            })
            .toolbar {
                ToolbarItem {
                    Button {
                       // Trigger options to share via AM or SP
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    
}

#Preview {
    MusicEntityDetailView(musicEntity: Utility.exampleEntity)
}
