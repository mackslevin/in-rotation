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
    
    // In the case that there happens to be something else already playing in the system player, make sure we still present a "play" button on initial load, rather than a "pause" button.
    @State private var isInitialState = true
    
    var body: some View {
        
        HStack(spacing: 50) {
            
            Button {
                isShowingOpenChooser = true
            } label: {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 36, weight: .bold))
            }
                
            if let sub = amAuthWrangler.musicSubscription, sub.canPlayCatalogContent {
//                Button {
//                    if isPlaying && !isInitialState {
//                        player.pause()
//                    } else {
//                        Task {
//                            do {
//                                try await viewModel.amWrangler.playInAppleMusicApp(recEntity.musicEntity)
//                            } catch {
//                                isShowingPlaybackError = true
//                            }
//                        }
//                    }
//                    
//                    isInitialState = false
//                } label: {
//                    Image(systemName: isInitialState ? "play.fill" : isPlaying ? "pause.fill" : "play.fill")
//                        .font(.system(size: 36, weight: .bold))
//                }
                
                AppleMusicPlayButton(musicEntity: recEntity.musicEntity)
                    .font(.system(size: 36, weight: .bold))
            }
            
            Menu {
                if !recEntity.musicEntity.appleMusicURLString.isEmpty {
                    ShareLink(item: URL(string: recEntity.musicEntity.appleMusicURLString)!) {
                        Label("Share Apple Music Link", systemImage: "square.and.arrow.up")
                    }
                }
                
                if !recEntity.musicEntity.spotifyURLString.isEmpty {
                    ShareLink(item: URL(string: recEntity.musicEntity.spotifyURLString)!) {
                        Label("Share Spotify Link", systemImage: "square.and.arrow.up")
                    }
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 36, weight: .bold))
            }
            .onAppear {
                Task {
                    await grabSpotifyURL()
                }
            }
        }
        .alert("PlaybackError", isPresented: $isShowingPlaybackError) {
            Button("OK"){}
        } message: {
            Text("Unable to play this item from Apple Music.")
        }
        .task {
//            await getPlaybackStateNotifications()
        }

    }
    
    func getPlaybackStateNotifications() async {
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil, queue: .main) { notification in
            
            if self.player.state.playbackStatus == .playing {
                self.isPlaying = true
            } else {
                self.isPlaying = false
            }
        }
    }
    
    func grabSpotifyURL() async {
        if recEntity.musicEntity.spotifyURLString.isEmpty {
            Task {
                if let urlStr = try? await SpotifyAPIWrangler().findMatch(forMusicEntity: recEntity.musicEntity) {
                    recEntity.musicEntity.spotifyURLString = urlStr
                }
            }
        }
    }
    
    
}

//#Preview {
//    
//    
//    
//    CardActionBlock(recEntity: RecommendationEntity(musicEntity: Utility.exampleEntity, recommendationSource: Utility.exampleEntity, blurb: "This is a cool album that we all love.", artist: abcArtist))
//}


