//
//  MusicEntityActionBlock.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI

struct MusicEntityActionBlock: View {
    @Bindable var musicEntity: MusicEntity
    @Binding var isShowingErrorAlert: Bool
    
    @State private var amWrangler = AppleMusicWrangler()
    @State private var spotifyWrangler = SpotifyAPIWrangler()
    
    @State private var played = false
    
    let buttonBGOpacity: Double = 1
    let buttonVerticalSpacing: CGFloat = 8
    
    var body: some View {
        VStack {
            HStack {
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
                    VStack(spacing: buttonVerticalSpacing) {
                        ZStack {
                            Circle()
                                .foregroundStyle(Color.secondary)
                                .opacity(buttonBGOpacity)
                                .shadow(radius: 3, x: 1, y: 3)
                            
                            Image(systemName: "arrow.up.right.square").resizable().scaledToFit()
                                .padding(16)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 60)
                        
                        Text("Apple Music")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                
                Spacer()
                
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
                    VStack(spacing: buttonVerticalSpacing) {
                        ZStack {
                            Circle()
                                .foregroundStyle(Color.secondary)
                                .opacity(buttonBGOpacity)
                                .shadow(radius: 3, x: 1, y: 3)
                            Image(systemName: "arrow.up.right.square").resizable().scaledToFit()
                                .padding(16)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 60)
                        
                        Text("Spotify")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                
                Spacer()
                
                
                VStack(spacing: buttonVerticalSpacing) {
                    ZStack {
                        Circle()
                            .foregroundStyle(played ? Color.secondary : Color.accentColor)
                            .opacity(buttonBGOpacity)
                            .shadow(radius: 3, x: 1, y: 3)
                        Image(systemName: played ? "circle.fill" : "circle").resizable().scaledToFit()
                            .padding(16)
                            .foregroundStyle(.white)
                    }
                    .frame(width: 60)
                    Text(played ? "Played" : "Unplayed")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
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
}

#Preview {
    VStack {
        Spacer()
        MusicEntityActionBlock(musicEntity: Utility.exampleEntity, isShowingErrorAlert: .constant(false))
        Spacer()
    }
    .padding()
    
}