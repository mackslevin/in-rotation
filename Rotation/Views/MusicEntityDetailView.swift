//
//  MusicEntityDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import MusicKit

struct MusicEntityDetailView: View {
    @Bindable var musicEntity: MusicEntity
    @State private var amWrangler = AppleMusicWrangler()
    @State private var isShowingErrorAlert = false
    @State private var alertMessage: String? = nil
    @State private var spotifyWrangler = SpotifyAPIWrangler()
    @Environment(\.appleMusicAuthWrangler) var amAuthWrangler
    @State private var isShowingAddedToLibrarySuccessAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if musicEntity.imageData != nil { // We're not gonna show the placeholder image
                        musicEntity.image.resizable().scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15) , radius: 5, x: 1, y: 5)
                    }
                    
                    MusicEntityHeadlineBlock(musicEntity: musicEntity)    
                    MusicEntityActionBlock(musicEntity: musicEntity, isShowingErrorAlert: $isShowingErrorAlert)
                    MusicEntityDetailsBlock(musicEntity: musicEntity)
                    MusicEntityTagsBlock(musicEntity: musicEntity)
                    MusicEntityNotesBlock(musicEntity: musicEntity)
                }
                .padding([.horizontal, .bottom])
                
                
            }
            .background {
                ZStack {
                    musicEntity.image.resizable().scaledToFill()
                    Rectangle()
                        .foregroundStyle(.thinMaterial)
                }
                .ignoresSafeArea()
            }
            .navigationTitle(Utility.stringForType(musicEntity.type))
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowingErrorAlert, content: {
                if let alertMessage {
                    Alert(title: Text("Something Went Wrong"), message: Text(alertMessage))
                } else {
                    Alert(title: Text("Something went wrong"))
                }
            })
            .alert(isPresented: $isShowingAddedToLibrarySuccessAlert, content: {
                Alert(title: Text("Added!"), message: Text("The item has been successfully added to your Apple Music Library"))
            })
            .toolbar {
                if !musicEntity.appleMusicURLString.isEmpty || !musicEntity.spotifyURLString.isEmpty {
                    ToolbarItem {
                        Menu {
                            if !musicEntity.appleMusicURLString.isEmpty, let amURL = URL(string: musicEntity.appleMusicURLString) {
                                ShareLink("Share Apple Music Link", item: amURL)
                            }
                            
                            if !musicEntity.spotifyURLString.isEmpty, let spURL = URL(string: musicEntity.spotifyURLString) {
                                ShareLink("Share Spotify Link", item: spURL)
                            }
                            
                            if let amSubscription = amAuthWrangler.musicSubscription, amSubscription.canPlayCatalogContent == true, amSubscription.hasCloudLibraryEnabled == true {
                                Button {
                                    addToLibrary()
                                } label: {
                                    Label("Add to Apple Music Library", systemImage: "plus")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                        }
                    }
                }
            }
            .onAppear {
                if musicEntity.appleMusicURLString.isEmpty {
                    Task {
                        try? await amWrangler.fillInAppleMusicInfo(musicEntity)
                    }
                }
                
                if musicEntity.spotifyURLString.isEmpty {
                    Task {
                        if let urlStr = try? await spotifyWrangler.findMatch(forMusicEntity: musicEntity) {
                            musicEntity.spotifyURLString = urlStr
                        }
                    }
                }
            }
        }
    }
    
    func addToLibrary() {
        Task {
            do {
                if let musicItem = try await amWrangler.appleMusicItemFromMusicEntity(musicEntity) {
                    if let item = musicItem as? MusicLibraryAddable {
                        try? await MusicLibrary.shared.add(item)
                        isShowingAddedToLibrarySuccessAlert = true
                    } else {
                        showLibraryFailureAlert()
                    }
                } else {
                    showLibraryFailureAlert()
                }
            } catch {
                showLibraryFailureAlert()
            }
        }
        
        
    }
    
    func showLibraryFailureAlert() {
        alertMessage = "The item could not be added to your library"
        isShowingErrorAlert = true
        alertMessage = nil
    }
}

#Preview {
    MusicEntityDetailView(musicEntity: Utility.exampleEntity)
}
