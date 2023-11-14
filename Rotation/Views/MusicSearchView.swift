//
//  MusicSearchView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData
import MusicKit

struct MusicSearchView: View {
    @State private var amSearchWrangler = AppleMusicSearchWrangler()
    @State private var amWrangler = AppleMusicWrangler()
    @State private var spotifyWrangler = SpotifyAPIWrangler()
    @State private var searchText = ""
    @State private var musicEntity: MusicEntity? = nil
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var isShowingErrorAlert = false
    @State private var errorAlertMessage: String? = nil
    let defaultErrorAlertMessage = "Something went wrong"
    
    var body: some View {
        NavigationStack {
            // MARK: Search box
            VStack(alignment: .leading) {
//                Text("Search")
//                    .font(.title)
//                    .bold()
                
                HStack {
                    TextField("Search for an album or song...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill").resizable().scaledToFit()
                            .frame(width: 24)
                    }
                    .tint(.secondary)
                    .disabled(searchText.isEmpty)
                }
                
                // MARK: Search results
                if amSearchWrangler.resultsExist() {
                    ScrollView(showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 12) {
                            if !amSearchWrangler.albumResults.isEmpty {
                                Text("Albums").font(.caption).bold().foregroundStyle(.secondary)
                            }
                            ForEach(amSearchWrangler.albumResults) { album in
                                Button {setEntity(album)} label: {
                                    HStack { Text("\(album.title) by \(album.artistName)"); Spacer() }
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            
                            if !amSearchWrangler.songResults.isEmpty {
                                Text("Songs").font(.caption).bold().foregroundStyle(.secondary)
                            }
                            ForEach(amSearchWrangler.songResults) { song in
                                Button {setEntity(song)} label: {
                                    HStack { Text("\(song.title) by \(song.artistName)"); Spacer() }
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
                
                // MARK: Music Entity
                if amSearchWrangler.isLoading {
                    ProgressView()
                } else if let musicEntity {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            if let data = musicEntity.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage).resizable().scaledToFit()
                                    .frame(maxWidth: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            Spacer()
                        }
                        VStack {
                            Text(musicEntity.title)
                            Text(musicEntity.artistName)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom)
                        
                        
                        Button("Add to Collection") {
                            modelContext.insert(musicEntity)
                            dismiss()
                        }
                        .bold()
                        .buttonStyle(.borderedProminent)
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
        .onChange(of: amSearchWrangler.searchError) { _, newValue in
            if newValue != nil { isShowingErrorAlert = true }
        }
//        .onChange(of: musicEntity, { oldValue, newValue in
//            amSearchWrangler.reset()
//        })
        .alert("Error", isPresented: $isShowingErrorAlert) {
            Button("OK"){}
        } message: {
            Text(errorAlertMessage ?? defaultErrorAlertMessage)
        }
    }
    
    func setEntity<T: MusicItem>(_ musicItem: T) {
        Task {
            musicEntity = await amSearchWrangler.makeMusicEntity(from: musicItem)
            await amSearchWrangler.reset()
            await Utility.dismissKeyboard()
        }
    }
}

#Preview {
    MusicSearchView()
}
