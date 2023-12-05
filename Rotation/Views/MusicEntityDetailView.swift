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
                    
                    if musicEntity.imageData != nil { // We're not gonna show the placeholder image
                        musicEntity.image.resizable().scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15) , radius: 5, x: 1, y: 5)
                    }
                    
                    MusicEntityHeadlineBlock(musicEntity: musicEntity)    
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
                        .foregroundStyle(.thinMaterial)
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
