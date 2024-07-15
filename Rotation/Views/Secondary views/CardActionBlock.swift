//
//  CardActionBlock.swift
//  Rotation
//
//  Created by Mack Slevin on 12/11/23.
//

import SwiftUI
import MusicKit

struct CardActionBlock: View {
    let recEntity: RecommendationEntity
    @Binding var isShowingOpenChooser: Bool
    let viewModel: ExploreViewModel
    
    @Environment(\.appleMusicAuthWrangler) var amAuthWrangler
    
    @State private var isShowingPlaybackError = false
    @State var player = SystemMusicPlayer.shared
    @State private var isPlaying = false
    @State private var isShowingShareOptions = false
    @State private var isInitialState = true
    
    var body: some View {
        
        HStack(spacing: 50) {
            Menu {
                ForEach(Array(recEntity.musicEntity.serviceLinks.keys).sorted().reversed(), id: \.self) { key in
                    Link(ServiceLinksCollection.serviceDisplayName(forServiceKey: key), destination: URL(string: recEntity.musicEntity.serviceLinks[key]!)!)
                }
            } label: {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 36, weight: .bold))
            }

            AppleMusicPlayButton(musicEntity: recEntity.musicEntity)
                .font(.system(size: 36, weight: .bold))
                .disabled(!(amAuthWrangler.musicSubscription?.canPlayCatalogContent ?? true))
            
            Menu {
                ForEach(Array(recEntity.musicEntity.serviceLinks.keys).sorted().reversed(), id: \.self) { key in
                    ShareLink(ServiceLinksCollection.serviceDisplayName(forServiceKey: key), item: URL(string: recEntity.musicEntity.serviceLinks[key]!)!)
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 36, weight: .bold))
            }
            .onDisappear {
                player.stop()
            }
        }
        .alert("PlaybackError", isPresented: $isShowingPlaybackError) {
            Button("OK"){}
        } message: {
            Text("Unable to play this item from Apple Music.")
        }
    }
}

//#Preview {
//    
//    
//    
//    CardActionBlock(recEntity: RecommendationEntity(musicEntity: Utility.exampleEntity, recommendationSource: Utility.exampleEntity, blurb: "This is a cool album that we all love.", artist: abcArtist))
//}


