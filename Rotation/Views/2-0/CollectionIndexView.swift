//
//  CollectionIndexView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI
import SwiftData

struct CollectionIndexView: View {
    @Environment(\.modelContext) var modelContext
    @Query var musicEntities: [MusicEntity]
    @State private var vm = CollectionIndexViewModel()
    
    var body: some View {
        NavigationSplitView {
            VStack {
                if musicEntities.isEmpty {
                    Button("Add some music to get started", systemImage: "plus") {
                        vm.shouldShowAddView.toggle()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .bold()
                } else {
                    List(selection: $vm.selectedEntityID) {
                        ForEach(vm.filteredMusicEntities(musicEntities, searchText: vm.searchText)) { musicEntity in
                            CollectionIndexRow(musicEntity: musicEntity, selectedID: $vm.selectedEntityID)
                                .swipeActions(edge: .trailing) {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        withAnimation { modelContext.delete(musicEntity) }
                                    }
                                    
                                    Button("Archive", systemImage: "archivebox") {
                                        withAnimation {
                                            musicEntity.archived.toggle()
                                        }
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button(musicEntity.played ? "Mark Unplayed" : "Mark Played", systemImage: "circle") {
                                        withAnimation { musicEntity.played.toggle() }
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $vm.searchText)
                }
            }
            .navigationTitle("Collection")
            .background { Color.customBG.ignoresSafeArea() }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu("List Options", systemImage: "line.horizontal.3.decrease.circle") {
                        Section {
                            Toggle("Reverse order", isOn: $vm.reverseSortOrder)
                        }
                        
                        Section {
                            Toggle("Show played", isOn: $vm.shouldShowPlayed)
                            Toggle("Show archived", isOn: $vm.shouldShowArchived)
                        }
                        
                        Section {
                            Picker("Select a sorting option", selection: $vm.collectionSorting) {
                                ForEach(CollectionSort.allCases) { sortOption in
                                    Text(sortOption.rawValue).tag(sortOption)
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus.circle") { vm.shouldShowAddView.toggle() }
                }
            }
            .sheet(isPresented: $vm.shouldShowAddView, content: {
                AddEntityView()
            })
            
        } detail: {
            NavigationStack {
                Group {
                    if let selectedEntityID = vm.selectedEntityID, let musicEntity = musicEntities.first(where: {$0.id == selectedEntityID}) {
                        MusicEntityDetailView(musicEntity: musicEntity)
                    } else {
                        NothingSelectedView()
                    }
                }
                .background { Color.customBG.ignoresSafeArea() }
            }
        }
        
    }
}

#Preview {
    PrimaryView()
        .modelContainer(for: MusicEntity.self)
}
