//
//  CollectionIndexViewModel.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import Foundation
import Observation

@Observable
class CollectionIndexViewModel {
    var selectedEntityID: UUID?
    var shouldShowAddView = false
    var searchText = ""
    
    func filteredMusicEntities(_ musicEntities: [MusicEntity], searchText: String) -> [MusicEntity] {
        guard !searchText.isEmpty else { return musicEntities }
        
        var matchingEntities: [MusicEntity] = []
        for entity in musicEntities {
            if entity.title.lowercased().contains(searchText.lowercased())
                ||
               entity.artistName.lowercased().contains(searchText.lowercased())
            {
                matchingEntities.append(entity)
            }
        }
        return matchingEntities
    }
}
