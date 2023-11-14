//
//  ScratchView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/7/23.
//

import SwiftUI
import MusicKit

struct ScratchView: View {
    @State private var amAuthWrangler = AppleMusicAuthWrangler()
    @State private var amSearchWrangler = AppleMusicSearchWrangler()
    @State private var searchText = ""
    @State private var isShowingErrorAlert = false
    @State private var musicEntity: MusicEntity? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Search...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom)
                
                if amSearchWrangler.resultsExist() {
                    VStack(alignment: .leading, spacing: 16) {
                        if !amSearchWrangler.albumResults.isEmpty {
                            Text("Albums").font(.caption).bold().foregroundStyle(.secondary)
                        }
                        ForEach(amSearchWrangler.albumResults, id: \.id) { album in
                            Button {
                                Task {
                                    await setMusicEntity(withItem: album)
                                }
                            } label: {
                                HStack { Text("\(album.title) by \(album.artistName)"); Spacer() }
                                    .multilineTextAlignment(.leading)
                            }
                            
                        }
                        
                        if !amSearchWrangler.songResults.isEmpty {
                            Text("Songs").font(.caption).bold().foregroundStyle(.secondary)
                        }
                        ForEach(amSearchWrangler.songResults, id: \.id) { song in
                            Button {
                                Task {
                                    await setMusicEntity(withItem: song)
                                }
                            } label: {
                                HStack { Text("\(song.title) by \(song.artistName)"); Spacer() }
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                        if !amSearchWrangler.playlistResults.isEmpty {
                            Text("Playlists").font(.caption).bold().foregroundStyle(.secondary)
                        }
                        ForEach(amSearchWrangler.playlistResults, id: \.id) { playlist in
                            Button {
                                Task {
                                    await setMusicEntity(withItem: playlist)
                                }
                            } label: {
                                HStack { Text(playlist.name) ; Spacer()}
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(Color.primary).colorInvert()
                            .shadow(color: .gray, radius: 10, x: 1, y: 10)
                    }
                }
                
                
                Spacer()
                
                if amSearchWrangler.isLoading {
                    ProgressView()
                } else if let musicEntity {
                    VStack(alignment: .leading, spacing: 12) {
                        if let data = musicEntity.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable().scaledToFit()
                                .frame(height: 300)
                        }
                        
                        Text("Title: \(musicEntity.title)")
                        Text("Artist: \(musicEntity.artistName)")
                        Text("Release Date: \(musicEntity.releaseDate.formatted())")
                        Text("Tracks: \(musicEntity.numberOfTracks)")
                        Text("Songs: \(musicEntity.songTitles.joined(separator: ", "))")
                        Text("Duration: \(musicEntity.duration.description)")
                    }
                    .bold()
                }
            }
            .padding()
        }
        .onChange(of: searchText) { oldValue, newValue in
            Task {
                await amSearchWrangler.search(withTerm: newValue)
            }
        }
        .onChange(of: amSearchWrangler.searchError) { oldValue, newValue in
            if newValue != nil {
                isShowingErrorAlert = true
            }
        }
        .alert("Error", isPresented: $isShowingErrorAlert) {
            Button("OK"){}
        } message: {
            Text(amSearchWrangler.searchError?.localizedDescription ?? "Something went wrong")
        }
        .task {
            await amAuthWrangler.requestMusicAuth()
            await amAuthWrangler.getMusicSubscriptionUpdates()
        }
    }
    
    func setMusicEntity<T: MusicItem>(withItem item: T) async {
        await amSearchWrangler.reset()
        musicEntity = await amSearchWrangler.makeMusicEntity(from: item)
    }
}

//#Preview {
//    ScratchView()
//}
