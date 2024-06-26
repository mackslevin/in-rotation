//
//  TagDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/25/24.
//

import SwiftUI

struct TagDetailView: View {
    @Bindable var tag: Tag
    @State private var isShowingSymbolPicker = false
    
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    Button("", systemImage: tag.symbolName) {
                        isShowingSymbolPicker.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .font(.system(size: 48))
                    .foregroundColor(.primary)
                    
                    TextField("Title", text: $tag.title)
                        .font(.displayFont(ofSize: 28))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible()),
                            count: horizontalSize == .regular ? 3 : 1
                            ),
                        alignment: .leading
                    ) {
                        ForEach(tag.musicEntities ?? []) { musicEntity in
                            VStack {
                                musicEntity.image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                                    .padding(.bottom)
                                
                                HStack {
                                    Button(musicEntity.played ? "Mark Unplayed" : "Mark Played", systemImage: musicEntity.played ? "circle" : "circle.fill") {
                                        withAnimation {
                                            musicEntity.played.toggle()
                                        }
                                    }
                                    .labelStyle(.iconOnly)
                                    .tint(Color.accentColor.gradient)
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Text(musicEntity.title)
                                            .lineLimit(1)
                                        Text(musicEntity.artistName)
                                            .font(.caption).bold().foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Menu("Actions", systemImage: "ellipsis.circle.fill") {
                                        Section {
                                            Menu("Share...", systemImage: "square.and.arrow.up.fill") {
                                                ForEach(Array(musicEntity.serviceLinks.keys).sorted(), id: \.self) { key in
                                                    if let urlString = musicEntity.serviceLinks[key], let url = URL(string: urlString) {
                                                        ShareLink(ServiceLinksCollection.serviceDisplayName(forServiceKey: key), item: url)
                                                    }
                                                }
                                            }
                                            Menu("Open in...", systemImage: "arrow.up.right.square.fill") {
                                                ForEach(Array(musicEntity.serviceLinks.keys).sorted(), id: \.self) { key in
                                                    if let urlString = musicEntity.serviceLinks[key], let url = URL(string: urlString) {
                                                        Link(ServiceLinksCollection.serviceDisplayName(forServiceKey: key), destination: url)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        Section {
                                            Button("Remove from tag", systemImage: "xmark", role: .destructive) {
                                                withAnimation {
                                                    // Possible SwiftData bug: Only removing the music entity from the tag's musicEntities array here causes a crash
                                                    tag.musicEntities?.removeAll(where: {$0.id == musicEntity.id})
                                                    musicEntity.tags?.removeAll(where: {$0.id == tag.id})
                                                }
                                            }
                                        }
                                        
                                    }
                                    .labelStyle(.iconOnly)
                                }
                            }
                            .padding()
                            .background {
                                ZStack {
                                    musicEntity.image.resizable().scaledToFill()
                                    Rectangle().foregroundStyle(.regularMaterial)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                            
                        }
                    }
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .padding()
                .navigationTitle("\(String(tag.musicEntities?.count ?? 0)) \(tag.musicEntities?.count == 1 ? "item" : "items")")
                .sheet(isPresented: $isShowingSymbolPicker) {
                    NavigationStack {
                        ScrollView {
                            SymbolPicker(symbolName: $tag.symbolName)
                                .padding()
                        }
                        .background {
                            Color.customBG.ignoresSafeArea()
                        }
                        .navigationTitle("Choose a Symbol")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close", systemImage: "xmark") {
                                    isShowingSymbolPicker.toggle()
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
}

//#Preview {
//    TagDetailView()
//}
