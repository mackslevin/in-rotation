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
            List(selection: $vm.selectedEntityID) {
                ForEach(vm.filteredMusicEntities(musicEntities, searchText: vm.searchText)) { musicEntity in
                    CollectionIndexRow(musicEntity: musicEntity)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                withAnimation { modelContext.delete(musicEntity) }
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
            .background { Color.customBG.ignoresSafeArea() }
            .navigationTitle("Collection")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Add", systemImage: "plus.circle") { vm.shouldShowAddView.toggle() }
                }
            }
            .sheet(isPresented: $vm.shouldShowAddView, content: {
                AddEntityView()
            })
            .searchable(text: $vm.searchText)
            
        } detail: {
            NavigationStack {
                Group {
                    if let selectedEntityID = vm.selectedEntityID, let musicEntity = musicEntities.first(where: {$0.id == selectedEntityID}) {
                        MusicEntityDetailView(musicEntity: musicEntity)
                    } else {
                        // TODO: Replace with something custom, including the custom font
                        ContentUnavailableView("Nothing Selected", systemImage: "questionmark.app.dashed")
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
