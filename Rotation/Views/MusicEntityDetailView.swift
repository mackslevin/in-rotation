//
//  MusicEntityDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI

struct MusicEntityDetailView: View {
    @Bindable var musicEntity: MusicEntity
    @State private var isShowingTagManager = false
    @State private var amWrangler = AppleMusicWrangler()
    @State private var isShowingErrorAlert = false
    @State private var spotifyWrangler = SpotifyAPIWrangler()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if musicEntity.imageData != nil { // We're not gonna show the placeholder image
                        musicEntity.image.resizable().scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                    }
                    
                    VStack {
                        Text(musicEntity.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.tint)
                        Text(musicEntity.artistName)
                    }
                    .font(.title)
                    .multilineTextAlignment(.center)
                    
                    VStack(spacing: 16) {
                        Toggle("Played", isOn: $musicEntity.played)
                            .frame(width: 180, height: 30)
                            
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
                            Text("Open in Apple Music")
                                .bold()
                                .frame(width: 180, height: 30)
                        }
                        .buttonStyle(.borderedProminent)
                        
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
                            Text("Open in Spotify")
                                .bold()
                                .frame(width: 180, height: 30)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if let tags = musicEntity.tags, tags.count > 0 {
                        HStack {
                            Text("Tags:").bold()
                            Text(tags.map({$0.title}).joined(separator: ", "))
                        }
                    }
                    
                    Button("Manage Tags") {
                        isShowingTagManager = true
                    }
                }
                .padding([.horizontal, .bottom])
                
                
            }
            .navigationTitle(musicEntity.title)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingTagManager, content: {
                TagManagerView(musicEntity: musicEntity)
            })
            .alert(isPresented: $isShowingErrorAlert, content: {
                Alert(title: Text("Something went wrong"))
            })
        }
    }
}

#Preview {
    MusicEntityDetailView(musicEntity: Utility.exampleEntity)
}
