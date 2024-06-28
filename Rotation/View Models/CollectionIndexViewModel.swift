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
    
    var shouldShowArchived = false
    var shouldShowPlayed = true
    
    func filteredMusicEntities(_ musicEntities: [MusicEntity], searchText: String) -> [MusicEntity] {
        var matchingEntities = musicEntities
        
        if !shouldShowPlayed { matchingEntities = matchingEntities.filter { !$0.played} }
        if !shouldShowArchived { matchingEntities = matchingEntities.filter { !$0.archived} }
        
        if !searchText.isEmpty {
            matchingEntities = matchingEntities.filter({
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.artistName.lowercased().contains(searchText.lowercased())
            })
        }
        
        return matchingEntities
    }
}
