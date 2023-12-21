//
//  MusicSearchView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData
import MusicKit

enum AddMode: CaseIterable {
    case search, url
}

struct MusicSearchView: View {
    @State private var amSearchWrangler = AppleMusicSearchWrangler()
    @State private var amWrangler = AppleMusicWrangler()
    @State private var spotifyWrangler = SpotifyAPIWrangler()
    @State private var searchText = ""
    @State private var musicEntity: MusicEntity? = nil
    @State private var addMode = AddMode.search
    @State private var urlString = ""
    @State private var musicURLWrangler = MusicURLWrangler()
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isShowingErrorAlert = false
    @State private var errorAlertMessage: String? = nil
    let defaultErrorAlertMessage = "Something went wrong"
    
    @State private var selectedTags: [Tag] = []
    @State private var isShowingTagToggler = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Picker("Add via...", selection: $addMode) {
                        Text("Search").tag(AddMode.search)
                        Text("Paste URL").tag(AddMode.url)
                    }
                    .pickerStyle(.segmented)
                    
                    if addMode == .search {
                        // MARK: Search box
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
                        .padding(.vertical)
                        
                        
                        // MARK: Search results
                        if amSearchWrangler.resultsExist(), !amSearchWrangler.isLoading {
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
                    } else if addMode == .url {
                        // MARK: URL Box
                        HStack {
                            TextField("URL", text: $urlString)
                                .textFieldStyle(.roundedBorder) // This is something that I am typing into this here computer. The cat loves this stuff.
                                .onSubmit {
                                    submitURL()
                                }
                                .keyboardType(.URL)
                            
                            Button {
                                if let pasteboardContents = UIPasteboard.general.string, URL(string: pasteboardContents) != nil {
                                    urlString = pasteboardContents
                                    submitURL()
                                } else {
                                    errorAlertMessage = "Pasteboard contents are not a valid URL"
                                    isShowingErrorAlert = true
                                }
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // MARK: Music Entity
                    if amSearchWrangler.isLoading || musicURLWrangler.isLoading {
                        HStack {
                            Spacer(); ProgressView(); Spacer()
                        }
                    } else if let musicEntity {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            
                            if let data = musicEntity.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage).resizable().scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            
                            VStack {
                                Text(musicEntity.title)
                                    .font(Font.displayFont(ofSize: 24))
                                Text("\(Utility.stringForType(musicEntity.type)) by \(musicEntity.artistName)")
                                    .foregroundStyle(.secondary)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                if let year = musicEntity.releaseYear() {
                                    Text(String(year))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            // TAGGING
                            HStack {
                                if selectedTags.isEmpty {
                                    Spacer()
                                    Button {
                                        isShowingTagToggler = true
                                    } label: {
                                        Label("Tag...", systemImage: "tag")
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                } else {
                                    VStack(spacing: 8) {
                                        LittleTagGrid(tags: selectedTags)
                                        
                                        Button("Edit Tags") {
                                            isShowingTagToggler = true
                                        }
                                        
                                    }
                                }
                            }
                            .padding(.vertical)
                            
                            
                            Button {
                                // TODO: Check IAP status 
                                modelContext.insert(musicEntity)
                                
                                musicEntity.tags = selectedTags
                                
                                dismiss()
                            } label: {
                                Label("Save to Collection", systemImage: "plus")
                            }
                            .bold()
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .navigationTitle("Search")
            
        }
        .onChange(of: searchText) { oldValue, newValue in
            musicEntity = nil // TODO: Just remove this so that the music entity doesn't go away until a new one is selected?
            Task {
                await amSearchWrangler.search(withTerm: newValue)
            }
        }
        .onChange(of: amSearchWrangler.searchError) { _, newValue in
            if newValue != nil { isShowingErrorAlert = true }
        }
        .alert("Error", isPresented: $isShowingErrorAlert) {
            Button("OK"){}
        } message: {
            Text(errorAlertMessage ?? defaultErrorAlertMessage)
        }
        .sheet(isPresented: $isShowingTagToggler) {
            TagTogglerView(selectedTags: $selectedTags)
        }
    }
    
    func setEntity<T: MusicItem>(_ musicItem: T) {
        Task {
            musicEntity = await amSearchWrangler.makeMusicEntity(from: musicItem)
            await amSearchWrangler.reset()
            await Utility.dismissKeyboard()
        }
    }
    
    func submitURL() {
        if let url = URL(string: urlString) {
            Task {
                do {
                    musicEntity = try await musicURLWrangler.musicEntityFromURL(url)
                } catch {
                    print(error)
                    if let urlError = error as? MusicURLWranglerError {
                        errorAlertMessage = urlError.rawValue
                    }
                    musicURLWrangler.isLoading = false
                    isShowingErrorAlert = true
                }
            }
        } else {
            musicURLWrangler.isLoading = false
            errorAlertMessage = "Invalid URL"
            isShowingErrorAlert = true
        }
    }
}

//#Preview {
//    MusicSearchView()
//}
