//
//  ExternalMusicSearchView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/8/23.
//

import SwiftUI
import MusicKit

struct ExternalMusicSearchView: View {
    @State private var amAuthWrangler = AppleMusicAuthWrangler()
    @State private var amSearchWrangler = AppleMusicSearchWrangler()
    @State private var amWrangler = AppleMusicWrangler()
    @State private var spotifyWrangler = SpotifyAPIWrangler()
    @State private var searchText = ""
    @State private var musicEntity: MusicEntity? = nil
    
    @State private var isShowingErrorAlert = false
    @State private var errorAlertMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Search")
                        .font(.title)
                        .bold()
                    
                    HStack {
                        TextField("Name an album, song, or playlist...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill").resizable().scaledToFit()
                                .frame(width: 24)
                        }
                        .tint(.secondary)
                        .disabled(searchText.isEmpty)
                    }
                }
                
                if amSearchWrangler.resultsExist() {
                    ScrollView(showsIndicators: true) {
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
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.ultraThinMaterial)
                    }
                }
                
                if amSearchWrangler.isLoading {
                    ProgressView()
                } else if let musicEntity {
                    if let data = musicEntity.imageData, let uiImage = UIImage(data: data) {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage).resizable().scaledToFit()
                                .frame(maxWidth: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            Spacer()
                        }
                        
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        RegularRow(key: "Title", value: musicEntity.title)
                        RegularRow(key: "By", value: musicEntity.artistName)
                        RegularRow(key: "Release Date", value: musicEntity.releaseDate.formatted())
                        RegularRow(key: "Track Count", value: String(musicEntity.numberOfTracks))
                    }
                    
                    VStack(spacing: 16) {
                        Button {
                            Task {
                                do {
                                    try await amWrangler.openInAppleMusic(musicEntity)
                                } catch {
                                    errorAlertMessage = error.localizedDescription
                                    isShowingErrorAlert = true
                                }
                            }
                        } label: {
                            Label("Open in Apple Music", systemImage: "apple.logo")
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(width: 300)
                        .fontWeight(.semibold)
                        
                        Button("Open in Spotify") {
                            Task {
                                do {
                                    try await spotifyWrangler.getAccessToken()
                                } catch {
                                    print("^^ spotify error! \(error.localizedDescription)")
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(width: 300)
                        .fontWeight(.semibold)
                    }
                    
                }
                
                Spacer()
            }
            .padding()
        }
        .onChange(of: searchText) { oldValue, newValue in
            musicEntity = nil
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
            Text(errorAlertMessage ?? "Something went wrong")
        }
        .task {
            await amAuthWrangler.requestMusicAuth()
            await amAuthWrangler.getMusicSubscriptionUpdates()
        }
    }
    
    func setMusicEntity<T: MusicItem>(withItem item: T) async {
        await Utility.dismissKeyboard()
        await amSearchWrangler.reset()
        musicEntity = await amSearchWrangler.makeMusicEntity(from: item)
    }
    
    struct RegularRow: View {
        let key: String
        let value: String
        var body: some View {
            HStack {
                Text(key.uppercased())
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                Spacer()
                Text(value)
            }
        }
    }
    
}

//#Preview {
//    ExternalMusicSearchView()
//}
