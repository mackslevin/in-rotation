//
//  ArchiveView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/15/23.
//

import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var searchTextIntermediary = ""
    @State private var isShowingSearch = false
    
    @State private var sortOrder = SortDescriptor(\MusicEntity.dateAdded, order: .reverse)
    @State private var showOnlyUnplayed = false
    @AppStorage("collectionSortCriteria") var collectionSortCriteria: CollectionSortCriteria = .dateAdded
    
    @State private var tagsForFiltering: [Tag] = []
    @Query var allTags: [Tag]
    
    
    @Query(filter: #Predicate<MusicEntity> {$0.archived == true}) var archivedMusicEntities: [MusicEntity]
    @State private var isShowingDeleteAllWarning = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Archive")
                        .font(Font.displayFont(ofSize: 32))
                        .foregroundStyle(.tint)
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            isShowingSearch = true
                        } label: {
                            Label("Search...", systemImage: "magnifyingglass")
                        }
                        
                        Toggle("Show unplayed only", isOn: $showOnlyUnplayed)
                        
                        Menu("Sort") {
                            Picker("Sort", selection: $collectionSortCriteria) {
                                Label("Title", systemImage: "text.quote")
                                    .tag(CollectionSortCriteria.byTitle)

                                Label("Artist Name", systemImage: "person.3")
                                    .tag(CollectionSortCriteria.byArtist)

                                Label("Date Added", systemImage: "calendar.circle")
                                    .tag(CollectionSortCriteria.dateAdded)

                                Label("Release Date", systemImage: "calendar.circle.fill")
                                    .tag(CollectionSortCriteria.releaseDate)
                            }
                            .pickerStyle(.inline)
                        }
                        
                        if !allTags.isEmpty {
                            Menu("Filter Tags...") {
                                ForEach(allTags) { tag in
                                    Button {
                                        if tagsForFiltering.contains(tag) {
                                            tagsForFiltering.removeAll(where: {$0.id == tag.id})
                                        } else {
                                            tagsForFiltering.append(tag)
                                        }
                                    } label: {
                                        HStack {
                                            Text(tag.title)
                                            
                                            if tagsForFiltering.contains(tag) {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                        Menu("Mark") {
                            Button {
                                for entity in archivedMusicEntities {
                                    withAnimation {
                                        entity.played = false
                                    }
                                }
                            } label: {
                                Label("Mark All Unplayed", systemImage: "circle")
                            }
                            
                            Button {
                                for entity in archivedMusicEntities {
                                    withAnimation {
                                        entity.played = true
                                    }
                                }
                            } label: {
                                Label("Mark All Played", systemImage: "circle.fill")
                            }
                        }
                        
                        Button(role: .destructive) {
                            isShowingDeleteAllWarning = true
                        } label: {
                            Label("Delete All", systemImage: "trash")
                        }
                        
                        
                    } label: {
                        Image(systemName: "ellipsis.circle").resizable().scaledToFit()
                            .frame(width: 30)
                            .padding([.trailing])
                    }
                    
                    Button("Close") {
                        dismiss()
                    }.bold().buttonStyle(.bordered)
                }
                .padding()
                
                if !tagsForFiltering.isEmpty {
                    HStack {
                        Text("Including tags: \(tagsForFiltering.map({$0.title}).joined(separator: ", "))")
                            .foregroundStyle(.secondary).italic()
                        Spacer()
                        Button {
                            tagsForFiltering = []
                        } label: {
                            Text("Clear")
                        }.buttonStyle(.bordered)
                    }
                    .font(.caption)
                    .padding()
                }
                
                if !searchText.isEmpty {
                    HStack {
                        Text("Search results for \"\(searchText)\"")
                            .italic().foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            searchText = ""
                        } label: {
                            Text("Clear")
                        }.buttonStyle(.bordered)
                    }
                    .font(.caption)
                    .padding()
                }
                
                CollectionListingView(sort: sortOrder, searchText: $searchText, showOnlyUnplayed: $showOnlyUnplayed, tagsForFiltering: $tagsForFiltering, isArchiveView: true)
                
                Spacer()
            }
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .sheet(isPresented: $isShowingSearch, content: {
                SearchboxView(searchText: $searchText, searchTextIntermediary: $searchTextIntermediary)
            })
            .onAppear {
                applySortCriterion(collectionSortCriteria)
            }
            .onChange(of: collectionSortCriteria) { _, newValue in
                applySortCriterion(newValue)
            }
            .alert("Are you sure?", isPresented: $isShowingDeleteAllWarning) {
                Button(role: .destructive) {
                    deleteAll()
                } label: {
                    Text("Delete")
                }
            } message: {
                Text("All archived items will be deleted. This cannot be undone.")
            }

        }
        
    }
    
    func applySortCriterion(_ criterion: CollectionSortCriteria) {
        switch criterion {
            case .dateAdded:
                sortOrder = SortDescriptor(\MusicEntity.dateAdded, order: .reverse)
            case .releaseDate:
                sortOrder = SortDescriptor(\MusicEntity.releaseDate, order: .reverse)
            case .byTitle:
                sortOrder = SortDescriptor(\MusicEntity.title)
            case .byArtist:
                sortOrder = SortDescriptor(\MusicEntity.artistName)
        }
    }
    
    func deleteAll() {
        for entity in archivedMusicEntities {
            withAnimation {
                modelContext.delete(entity)
            }
        }
    }
}

#Preview {
    ArchiveView()
}
