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
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background {Rectangle().foregroundStyle(.primary).colorInvert()}
                    .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.1) , radius: 5, x: 2, y: 4)
                    .submitLabel(.search)
                    .focused($searchBoxIsFocused)
                    .autocorrectionDisabled()
                    .padding(.bottom)
                
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
            .onChange(of: amSearchWrangler.searchError) { oldValue, newValue in
                if newValue != nil {
                    vm.shouldShowError = true
                }
            }
            .alert("Error", isPresented: $vm.shouldShowError) { Button("OK"){} }
        }
    }
}

#Preview {
//    AddEntityView()
    PrimaryView()
        .modelContainer(for: MusicEntity.self)
        .environment(AppleMusicSearchWrangler())
        
}
