//
//  CollectionListingView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/1/23.
//

import SwiftUI
import SwiftData

struct CollectionListingView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<MusicEntity> { return !$0.title.isEmpty }, sort: [SortDescriptor(\MusicEntity.dateAdded)]) var musicEntities: [MusicEntity]
    
    @Binding var searchText: String
    @Binding var showOnlyUnplayed: Bool
    @Binding var tagsForFiltering: [Tag]
    
    var body: some View {
        if musicEntities.isEmpty {
            VStack(spacing: 40) {
                Spacer()
                VStack(spacing: 40) {
                    Image(systemName: "eyes")
                        .resizable().scaledToFit()
                        .frame(width: 100)
                    Text("Nothing here yet...")
                        .font(.displayFont(ofSize: 28))
                }
                .foregroundStyle(.secondary)
                
                NavigationLink("Add some music to get started", destination: MusicSearchView())
                    .buttonStyle(.borderedProminent).bold()
                Spacer()
            }
            
        } else {
            List {
                ForEach(musicEntities) { musicEntity in
                    if musicEntity.title.localizedStandardContains(searchText) ||
                        musicEntity.artistName.localizedStandardContains(searchText) ||
                        searchText.isEmpty
                    {
                        if handleUnplayedFilter(forMusicEntity: musicEntity) && handleTagFiltering(forMusicEntity: musicEntity) {
                            CollectionListingViewRow(musicEntity: musicEntity)
                            
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        
    }
    
    
    init(sort: SortDescriptor<MusicEntity>, searchText: Binding<String>, showOnlyUnplayed: Binding<Bool>, tagsForFiltering: Binding<[Tag]>) {
        _musicEntities = Query(sort: [sort])
        _searchText = searchText
        _showOnlyUnplayed = showOnlyUnplayed
        _tagsForFiltering = tagsForFiltering
    }
    
    func handleUnplayedFilter(forMusicEntity musicEntity: MusicEntity) -> Bool {
        if showOnlyUnplayed && musicEntity.played {
            return false
        }
        
        return true
    }
    
    func handleTagFiltering(forMusicEntity musicEntity: MusicEntity) -> Bool {
        if !tagsForFiltering.isEmpty {
            for tag in tagsForFiltering {
                if let existingTags = musicEntity.tags {
                    if existingTags.contains(tag) {
                        return true
                    }
                }
            }
            
            return false
        }
        
        return true
    }
}

//#Preview {
//    CollectionListingView(sort: SortDescriptor(\MusicEntity.dateAdded), searchText: "")
//}
