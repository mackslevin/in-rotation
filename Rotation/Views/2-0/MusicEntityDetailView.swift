//
//  MusicEntityDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI
import SwiftData

struct MusicEntityDetailView: View {
    @Bindable var musicEntity: MusicEntity
    @Environment(\.horizontalSizeClass) var horizontalSize
    @State private var vm = DetailViewModel()
    @Environment(AppleMusicWrangler.self) var amWrangler
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack() {
                    
                    LazyVGrid(columns: 
                                horizontalSize == .compact ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())], content: {
                        
                        VStack {
                            if musicEntity.imageData != nil {
                                musicEntity.image.resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(maxWidth: 500, maxHeight: 500)
                                    .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                            }
                            
                            MusicEntityHeadlineBlock(musicEntity: musicEntity)
                            
                            MusicEntityActionBlock(musicEntity: musicEntity)
                            
                            Spacer()
                        }
                        
                        VStack {
                            MusicEntityDetailsBlock(musicEntity: musicEntity)
                            
                            MusicEntityTagsBlock(musicEntity: musicEntity)
                            
                            MusicEntityNotesBlock(musicEntity: musicEntity)
                            
                            Spacer()
                        }
                    })
                    
                    
                    
                }
                .padding()
                
                
            }
            .navigationTitle(musicEntity.title)
            .navigationBarTitleDisplayMode(.inline)
            .background {
                ZStack {
                    musicEntity.image.resizable().scaledToFill()
                    Rectangle()
                        .foregroundStyle(.thinMaterial)
                }
                .ignoresSafeArea()
            }
            .toolbar {
                Menu("More", systemImage: "ellipsis.circle.fill") {
                    if !musicEntity.serviceLinks.isEmpty {
                        Menu("Share...", systemImage: "square.and.arrow.up.fill") {
                            ForEach(Array(musicEntity.serviceLinks.keys), id: \.self) { key in
                                if let urlString = musicEntity.serviceLinks[key], let url = URL(string: urlString) {
                                    ShareLink(ServiceLinksCollection.serviceDisplayName(forServiceKey: key), item: url)
                                }
                            }
                        }
                    }
                    
                    if let isAdded = vm.isSavedToUserLibrary {
                        Button(isAdded ? "Added to Music Library" : "Add to Music Library", systemImage: isAdded ? "checkmark" : "plus") {
                            Task {
                                await vm.addToUserLibrary(musicEntity, appleMusicWrangler: amWrangler)
                                vm.isShowingAddSuccess = true
                                vm.isSavedToUserLibrary = true
                            }
                        }
                        .disabled(isAdded)
                    }
                }
            }
            .task {
                try? await vm.setUp(musicEntity)
            }
            .alert("The item was successfully added to your library", isPresented: $vm.isShowingAddSuccess) {
                Button("OK"){}
            }
        }
    }
}

#Preview {
    NavigationStack {
        MusicEntityDetailView(musicEntity: Utility.exampleEntity)
    }
}
