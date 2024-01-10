//
//  MusicEntityActionBlock.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI
import MediaPlayer
import MusicKit

struct MusicEntityActionBlock: View {
    @Bindable var musicEntity: MusicEntity
    @Binding var isShowingErrorAlert: Bool
    
    @State private var amWrangler = AppleMusicWrangler()
    @State private var spotifyWrangler = SpotifyAPIWrangler()
    
    @State private var played = false
    
    @AppStorage("shouldPlayInAppleMusicApp") var shouldPlayInAppleMusicApp = true
    
    @Environment(\.appleMusicAuthWrangler) var amAuthWrangler
    
    let actionIconSize: CGFloat = 36

    
    var body: some View {
        VStack {
            HStack {
                
                if shouldPlayInAppleMusicApp, let sub = amAuthWrangler.musicSubscription, sub.canPlayCatalogContent {
                    VStack {
                        AppleMusicPlayButton(musicEntity: musicEntity)
                            .font(.system(size: actionIconSize, weight: .bold))
                        Text("Apple Music")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                    }
                    .frame(width: 75)
                } else {
                    if !musicEntity.appleMusicURLString.isEmpty {
                        Button {
                            Task {
                                do {
                                    try await amWrangler.openInAppleMusic(musicEntity)
                                } catch {
                                    print(error)
                                    isShowingErrorAlert = true
                                }
                            }
                        } label: {
                            VStack() {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: actionIconSize, weight: .bold))
                                
                                Text("Apple Music")
                                    .font(.system(size: 12))
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(width: 75)
                    }
                }
                
                
                Spacer()
                
                if !musicEntity.spotifyURLString.isEmpty {
                    Button {
                        Task {
                            do {
                                try await spotifyWrangler.openInSpotify(musicEntity)
                            } catch {
                                print(error)
                                isShowingErrorAlert = true
                            }
                            
                        }
                    } label: {
                        VStack() {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: actionIconSize, weight: .bold))
                            
                            Text("Spotify")
                                .font(.system(size: 12))
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(width: 75)
                }
                
                
                Spacer()
                    
                VStack {
                    Image(systemName: played ? "circle.fill" : "circle")
                        .font(.system(size: actionIconSize, weight: .bold))
                        .foregroundStyle(played ? Color.primary : Color.accentColor)
                    Text(played ? "Played" : "Unplayed")
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                }
                .frame(width: 75)
                .onTapGesture {
                    withAnimation {
                        played.toggle()
                    }
                }
            }
            .padding()
            .tint(.primary)
        }
        .background {
            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false))
                .foregroundStyle(.regularMaterial)
        }
        .onAppear {
            played = musicEntity.played
        }
        .onChange(of: played) { _, newValue in
            musicEntity.played = newValue
        }
        
    }
    
    func playInAppleMusicApp() {
        Task {
            do {
                try await amWrangler.playInAppleMusicApp(musicEntity)
            } catch {
                print("^^ playback error")
                isShowingErrorAlert = true
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        MusicEntityActionBlock(musicEntity: Utility.exampleEntity, isShowingErrorAlert: .constant(false))
        Spacer()
    }
    .padding()
    
}
