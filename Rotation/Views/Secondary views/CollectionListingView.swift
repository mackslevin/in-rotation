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
    
    var body: some View {
        List {
            ForEach(musicEntities) { musicEntity in
                if musicEntity.title.localizedStandardContains(searchText) || musicEntity.artistName.localizedStandardContains(searchText) || searchText.isEmpty {
                    NavigationLink {
                        MusicEntityDetailView(musicEntity: musicEntity)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(musicEntity.title)
                                .fontWeight(.semibold)
                            Text(musicEntity.artistName)
                            Text(musicEntity.played ? "Played" : "Unplayed")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
    }
    
    
    init(sort: SortDescriptor<MusicEntity>, searchText: Binding<String>) {
        _musicEntities = Query(sort: [sort])
        _searchText = searchText
    }
}
//
//#Preview {
//    CollectionListingView(sort: SortDescriptor(\MusicEntity.dateAdded), searchText: "")
//}
