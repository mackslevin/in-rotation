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
    
    @State private var isShowingPlaybackError = false
    
    @State var player = SystemMusicPlayer.shared
    @State private var isPlaying = false
    
    // In the case that there happens to be something else already playing in the system player, make sure we still present a "play" button on initial load, rather than a "pause" button.
    @State private var isInitialState = true
    
    var body: some View {
        
        VStack {
                
            Button {
                if isPlaying && !isInitialState {
                    player.pause()
                } else {
                    Task {
                        do {
                            try await viewModel.amWrangler.playInAppleMusicApp(recEntity.musicEntity)
                        } catch {
                            isShowingPlaybackError = true
                        }
                    }
                }
                
                isInitialState = false
            } label: {
                Image(systemName: isInitialState ? "play" : isPlaying ? "pause" : "play")
                    .font(.largeTitle)
            }
            
            
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true))
                .foregroundStyle(.regularMaterial)
        }
        .alert("PlaybackError", isPresented: $isShowingPlaybackError) {
            Button("OK"){}
        } message: {
            Text("Unable to play this item from Apple Music.")
        }
        .task {
            await getPlaybackStateNotifications()
        }

    }
    
    func getPlaybackStateNotifications() async {
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil, queue: .main) { notification in
            
            if self.player.state.playbackStatus == .playing {
                self.isPlaying = true
            } else {
                self.isPlaying = false
            }
            print("^^ System playback state changed: \(self.isPlaying ? "playing" : "not playing")")
        }
    }
    
    
}

//#Preview {
//    
//    
//    
//    CardActionBlock(recEntity: RecommendationEntity(musicEntity: Utility.exampleEntity, recommendationSource: Utility.exampleEntity, blurb: "This is a cool album that we all love.", artist: abcArtist))
//}


