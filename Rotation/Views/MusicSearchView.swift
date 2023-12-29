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
    
//    @State private var selectedTags: [Tag] = []
//    @State private var isShowingTagToggler = false
    
//    @State private var isShowingIAPSheet = false
//    @State private var userHasPremiumAccess = false
//    @Query var allMusicEntites: [MusicEntity]
    
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
                                .submitLabel(.done)
                                .autocorrectionDisabled()
                                .padding()
                                .background {
                                    if colorScheme == .light {
                                        Color.primary.colorInvert()
                                    } else {
                                        Color.primary.opacity(0.2)
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                                .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.1) , radius: 4, x: 1, y: 3)
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
                                        LiveResultsRow(song: nil, album: album) {
                                            setEntity(album)
                                        }
                                    }
                                    
                                    if !amSearchWrangler.songResults.isEmpty {
                                        Text("Songs").font(.caption).bold().foregroundStyle(.secondary)
                                    }
                                    ForEach(amSearchWrangler.songResults) { song in
                                        LiveResultsRow(song: song, album: nil) {
                                            setEntity(song)
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
                                .onSubmit {
                                    submitURL()
                                }
                                .keyboardType(.URL)
                                .padding()
                                .background {
                                    if colorScheme == .light {
                                        Color.primary.colorInvert()
                                    } else {
                                        Color.primary.opacity(0.2)
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                                .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.1) , radius: 4, x: 1, y: 3)
                            
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
//                    if amSearchWrangler.isLoading || musicURLWrangler.isLoading {
//                        HStack {
//                            Spacer(); ProgressView(); Spacer()
//                        }
//                    } else if let musicEntity {
//                        Spacer()
//                        
//                        VStack(spacing: 12) {
//                            
//                            if let data = musicEntity.imageData, let uiImage = UIImage(data: data) {
//                                Image(uiImage: uiImage).resizable().scaledToFit()
//                                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                            }
//                            
//                            VStack {
//                                Text(musicEntity.title)
//                                    .font(Font.displayFont(ofSize: 24))
//                                Text("\(Utility.stringForType(musicEntity.type)) by \(musicEntity.artistName)")
//                                    .foregroundStyle(.secondary)
//                                    .fontWeight(.semibold)
//                                    .multilineTextAlignment(.center)
//                                if let year = musicEntity.releaseYear() {
//                                    Text(String(year))
//                                        .foregroundStyle(.secondary)
//                                }
//                            }
//                            
//                            // TAGGING
//                            VStack {
//                                if selectedTags.isEmpty {
//                                    Button {
//                                        isShowingTagToggler = true
//                                    } label: {
//                                        Label("Tag...", systemImage: "tag")
//                                            .fontWeight(.semibold)
//                                            .frame(minWidth: 100)
//                                    }
//                                    .buttonStyle(.bordered)
//                                } else {
//                                    VStack {
//                                        Text("Tags: \(selectedTags.map({$0.title}).joined(separator: ", ") )")
//                                            .foregroundStyle(.secondary)
//                                        
//                                        Button("Edit") {
//                                            isShowingTagToggler = true
//                                        }.bold()
//                                    }
//                                    .font(.caption)
//                                }
//                            }
//                            .padding(.vertical)
//                            
//                            
//                            Button {
//                                if allMusicEntites.count >= Utility.maximumFreeEntities && !userHasPremiumAccess {
//                                    isShowingIAPSheet = true
//                                } else {
//                                    modelContext.insert(musicEntity)
//                                    musicEntity.tags = selectedTags
//                                    dismiss()
//                                }
//                            } label: {
//                                Label("Save", systemImage: "plus")
//                                    .frame(minWidth: 100)
//                            }
//                            .bold()
//                            .buttonStyle(.borderedProminent)
//                        }
//                    }
                    
                    if amSearchWrangler.isLoading || musicURLWrangler.isLoading {
                        HStack {
                            Spacer(); ProgressView(); Spacer()
                        }
                    } else if let musicEntity {
                        MusicEntityAddingView(musicEntity: musicEntity) {
                            dismiss()
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                
            }
            .scrollIndicators(.hidden)
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .navigationTitle("Search")
            
        }
        .onChange(of: searchText) {_, newValue in
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
//        .sheet(isPresented: $isShowingTagToggler) {
//            TagTogglerView(selectedTags: $selectedTags)
//        }
//        .currentEntitlementTask(for: Utility.premiumUnlockProductID) { state in
//            switch state {
//                case .loading:
//                    print("^^ state is loading")
//                case .failure(let error):
//                    print("^^ state failed, error is \(error)")
//                case .success(let transaction):
//                    print("^^ state is success")
//                    userHasPremiumAccess = transaction != nil
//                @unknown default:
//                    fatalError()
//            }
//        }
//        .sheet(isPresented: $isShowingIAPSheet) {
//            IAPPaywallView()
//        }
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
