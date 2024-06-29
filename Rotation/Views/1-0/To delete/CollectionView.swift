//
//  CollectionView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @State private var searchText = ""
    @State private var searchTextIntermediary = ""
    @State private var isShowingSearch = false
    
    @State private var sortOrder = SortDescriptor(\MusicEntity.dateAdded, order: .reverse)
    @State private var showOnlyUnplayed = false
    @AppStorage("collectionSortCriteria") var collectionSortCriteria: CollectionSortCriteria = .dateAdded
    
    @State private var tagsForFiltering: [Tag] = []
    @Query var allTags: [Tag]
    
    @State private var isShowingArchive = false
    
    @Query var musicEntities: [MusicEntity]
    @State private var isShowingArchiveAllWarning = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Collection")
                        .font(Font.displayFont(ofSize: 32))
                        .foregroundStyle(.tint)
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            isShowingSearch = true
                        } label: {
                            Label("Search...", systemImage: "magnifyingglass")
                        }
                        
                        
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
                                for entity in musicEntities {
                                    withAnimation {
                                        entity.played = false
                                    }
                                }
                            } label: {
                                Label("Mark All Unplayed", systemImage: "circle")
                            }
                            Button {
                                for entity in musicEntities {
                                    withAnimation {
                                        entity.played = true
                                    }
                                }
                            } label: {
                                Label("Mark All Played", systemImage: "circle.fill")
                            }
                        }
                        
                        Toggle("Show unplayed only", isOn: $showOnlyUnplayed)
                        
                        Button {
                            isShowingArchive = true
                        } label: {
                            Label("View archived items...", systemImage: "archivebox")
                        }
                        
                        Button {
                            isShowingArchiveAllWarning = true
                        } label: {
                            Label("Archive All", systemImage: "archivebox.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle").resizable().scaledToFit()
                            .frame(width: 30)
                            .padding([.trailing])
                    }
                    
                    NavigationLink(destination: MusicSearchView()) {
                        Image(systemName: "plus.circle").resizable().scaledToFit()
                            .frame(width: 30)
                    }
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
                
                CollectionListingView(sort: sortOrder, searchText: $searchText, showOnlyUnplayed: $showOnlyUnplayed, tagsForFiltering: $tagsForFiltering, isArchiveView: false)
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
            .sheet(isPresented: $isShowingArchive) {
                ArchiveView()
            }
            .alert("Are you sure?", isPresented: $isShowingArchiveAllWarning) {
                Button("Cancel"){}
                Button("Archive All") {
                    archiveAll()
                }
            } message: {
                Text("All items in the collection will be moved to the archive.")
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
    
    func archiveAll() {
        for entity in musicEntities {
            withAnimation {
                entity.archived = true
            }
        }
    }
}

#Preview {
    CollectionView()
}