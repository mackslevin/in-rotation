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
            
//            guard thisRecordIsCurrentlyPlaying() else {
//                playFromTheTop()
//                isInitialState = false
//                return
//            }
            
            print("^^ this record is currently queued")
            
            
            if isInitialState {
                playFromTheTop()
            } else {
                if player.state.playbackStatus == .playing {
                    print("^^ is playing")
                    player.pause()
                } else {
                    print("^^ is NOT playing")
                    Task {
                        do {
                            try await player.play()
                            buttonSymbolName = "pause.fill" // Workaround for playback state notification not firing on time in some cases
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
//        .onChange(of: player.state.playbackStatus) { _, newValue in
//            if !isInitialState {
//                if newValue == .playing {
//                    buttonSymbolName = "pause.fill"
//                } else {
//                    buttonSymbolName = "play.fill"
//                }
//            }
//        }
        .onChange(of: isInitialState) { oldValue, newValue in
            print("^^ initial state \(newValue)")
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
    
//    func thisRecordIsCurrentlyPlaying() -> Bool {
//        guard let currentlyQueuedSong = player.queue.currentEntry?.item as? Song else {
//            print("^^ no currently queued song")
//            print("^^ uhh \(player.queue.currentEntry?.item)")
//            return false
//        }
//        
//        currentlyQueuedSong
//
//        switch musicEntity.type {
//            case .song:
//                if let isrc = currentlyQueuedSong.isrc, isrc == musicEntity.isrc {
//                    print("^^ isrc match ")
//                    return true
//                } else {
//                    print("^^ NO isrc match ")
//                }
//            default:
//                if musicEntity.songTitles.contains(currentlyQueuedSong.title) {
//                    print("^^ first song match")
//                    return true
//                }
//        }
//        
//        return false
//    }
}

#Preview {
    AppleMusicPlayButton(musicEntity: Utility.exampleEntity)
}
