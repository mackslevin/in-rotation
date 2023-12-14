//
//  MusicEntityPlayButton.swift
//  Rotation
//
//  Created by Mack Slevin on 12/13/23.
//

import SwiftUI
import MusicKit
import MediaPlayer

struct AppleMusicPlayButton: View {
    let musicEntity: MusicEntity
    
    @Environment(\.appleMusicAuthWrangler) var amAuthWrangler
    @State private var isShowingPlaybackError = false
    @State var player = SystemMusicPlayer.shared
    @State private var isPlaying = false
    @State private var isInitialState = true
    @State private var amWrangler = AppleMusicWrangler()
    
    @State private var buttonSymbolName = "play.fill"
    
    var body: some View {
        Button {
            guard let sub = amAuthWrangler.musicSubscription, sub.canPlayCatalogContent else {
                isShowingPlaybackError = true
                return
            }
            
            if isInitialState {
                playFromTheTop()
            } else {
                if player.state.playbackStatus == .playing {
                    player.pause()
                } else {
                    Task {
                        do {
                            try await player.play()
                            buttonSymbolName = "pause.fill" // Workaround for playback state notification apparently not firing on time in some cases
                        } catch {
                            print(error)
                            isShowingPlaybackError = true
                        }
                    }
                }
            }
            
            isInitialState = false
        } label: {
            Image(systemName: buttonSymbolName)
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
            
            if let playerController = notification.object as? MPMusicPlayerController, !isInitialState {
                if playerController.playbackState == .playing {
                    buttonSymbolName = "pause.fill"
                } else {
                    buttonSymbolName = "play.fill"
                }
            }
        }
    }
    
    func playFromTheTop() {
        Task {
            do {
                try await amWrangler.playInAppleMusicApp(musicEntity)
            } catch {
                isShowingPlaybackError = true
            }
        }
    }
}

#Preview {
    AppleMusicPlayButton(musicEntity: Utility.exampleEntity)
}
