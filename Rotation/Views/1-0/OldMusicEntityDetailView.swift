//
//  MusicEntityDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import MusicKit

struct OldMusicEntityDetailView: View {
    @Bindable var musicEntity: MusicEntity
    @State private var amWrangler = AppleMusicWrangler()
    @State private var isShowingErrorAlert = false
    @State private var alertMessage: String? = nil
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
            .alert(isPresented: $isShowingAddedToLibrarySuccessAlert, content: {
                Alert(title: Text("Added!"), message: Text("The item has been successfully added to your Apple Music Library"))
            })
            .toolbar {
                if !musicEntity.appleMusicURLString.isEmpty || musicEntity.serviceLinks["spotify"] != nil {
                    ToolbarItem {
                        Menu {
                            if !musicEntity.appleMusicURLString.isEmpty, let amURL = URL(string: musicEntity.appleMusicURLString) {
                                ShareLink("Share Apple Music Link", item: amURL)
                            }
                            
                            if let urlStr = musicEntity.serviceLinks["spotify"], let spURL = URL(string: urlStr) {
                                ShareLink("Share Spotify Link", item: spURL)
                            }
                            
                            if let amSubscription = amAuthWrangler.musicSubscription, amSubscription.canPlayCatalogContent == true, amSubscription.hasCloudLibraryEnabled == true {
                                Button {
                                    addToLibrary()
                                } label: {
                                    Label("Add to Apple Music Library", systemImage: "plus")
                                }
                                .alert(isPresented: $isShowingErrorAlert, content: {
                                    Alert(title: Text(alertMessage ?? "Something went wrong"))
                                })
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
                
                if musicEntity.serviceLinks.isEmpty, !musicEntity.appleMusicURLString.isEmpty {
                    Task {
                        if let linkCollection = try await ServiceLinksCollection.linkCollection(fromServiceURL: musicEntity.appleMusicURLString) {
                            musicEntity.serviceLinks = linkCollection.simpleLinks
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
                        try await MusicLibrary.shared.add(item)
                        isShowingAddedToLibrarySuccessAlert = true
                    } else {
                        showLibraryFailureAlert(message: nil)
                    }
                } else {
                    showLibraryFailureAlert(message: nil)
                }
            } catch {
                print("^^ gahhhh")
                
                await MainActor.run {
                    showLibraryFailureAlert(message: error.localizedDescription)
                }
                
            }
        }
        
        
    }
    
    func showLibraryFailureAlert(message: String?) {
        if let message {
            alertMessage = message
        } else {
            alertMessage = "The item could not be added to your library."
        }
        
        isShowingErrorAlert = true
        alertMessage = nil
    }
}

#Preview {
    OldMusicEntityDetailView(musicEntity: Utility.exampleEntity)
}
