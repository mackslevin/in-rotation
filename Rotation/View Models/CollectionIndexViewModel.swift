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
    var collectionSorting: CollectionSort = .dateAdded
    var reverseSortOrder = false
    
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
        
        switch collectionSorting {
            case .dateAdded:
                matchingEntities = matchingEntities.sorted(by: {$0.dateAdded > $1.dateAdded})
            case .alphabeticalByTitle:
                matchingEntities = matchingEntities.sorted(by: {$0.title < $1.title})
            case .alphabeticalByArtist:
                matchingEntities = matchingEntities.sorted(by: {$0.artistName < $1.artistName})
        }
        
        if reverseSortOrder { matchingEntities = matchingEntities.reversed() }
        
        return matchingEntities
    }
}
