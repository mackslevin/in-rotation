//
//  AddEntityView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI

struct AddEntityView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(AppleMusicSearchWrangler.self) var amSearchWrangler
    @FocusState private var searchBoxIsFocused: Bool
    @State private var vm = AddEntityViewModel()
    
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search music...", text: $vm.searchText)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.search)
                    .focused($searchBoxIsFocused)
                    .autocorrectionDisabled()
                
                
                // MARK: Search Results
                if amSearchWrangler.resultsExist(), !amSearchWrangler.isLoading {
                    ScrollView(showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 12) {
                            if !amSearchWrangler.albumResults.isEmpty {
                                Text("Albums").font(.caption).bold().foregroundStyle(.secondary)
                            }
                            ForEach(amSearchWrangler.albumResults) { album in
                                LiveResultsRow(song: nil, album: album) {
                                    Task {
                                        await vm.setMusicEntity(album)
                                        searchBoxIsFocused = false
                                    }
                                }
                            }
                            
                            if !amSearchWrangler.songResults.isEmpty {
                                Text("Songs").font(.caption).bold().foregroundStyle(.secondary)
                            }
                            ForEach(amSearchWrangler.songResults) { song in
                                LiveResultsRow(song: song, album: nil) {
                                    Task {
                                        await vm.setMusicEntity(song)
                                        searchBoxIsFocused = false
                                    }
                                }
                            }
                        }
                    }
                }
                
                // MARK: Selected Music Entity
                if amSearchWrangler.isLoading {
                    HStack {
                        Spacer(); ProgressView(); Spacer()
                    }
                } else if let musicEntity = vm.newMusicEntity {
                    ScrollView {
                        MusicEntityAddingView(musicEntity: musicEntity) {
                            dismiss()
                        }
                    }
                }
                
                Spacer()
                
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", action: { dismiss() })
                }
            }
            .padding()
            .navigationTitle("Add Music")
            .background { Color.customBG.ignoresSafeArea() }
            .onAppear {
                searchBoxIsFocused = true
            }
            .onChange(of: vm.searchText) { oldValue, newValue in
                vm.newMusicEntity = nil
                Task {
                    await amSearchWrangler.search(withTerm:vm.searchText)
                }
            }
        }
    }
}

#Preview {
//    AddEntityView()
    PrimaryView()
        .modelContainer(for: MusicEntity.self)
        .environment(AppleMusicSearchWrangler())
        
}