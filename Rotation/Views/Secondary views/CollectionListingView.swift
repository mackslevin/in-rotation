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
    @Query(sort: \MusicEntity.dateAdded, order: .reverse) var musicEntities: [MusicEntity]
    
    var body: some View {
        List {
            ForEach(musicEntities) { musicEntity in
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
        .listStyle(.plain)
        
    }
    
    
    init(sort: SortDescriptor<MusicEntity>, searchText: String) {
        _musicEntities = Query(filter: #Predicate {
            if searchText.isEmpty {
                return true
            } else {
                return $0.title.localizedStandardContains(searchText) || $0.artistName.localizedStandardContains(searchText)
            }
        }, sort: [sort])
    }
}

#Preview {
    CollectionListingView(sort: SortDescriptor(\MusicEntity.dateAdded), searchText: "")
}
