//
//  CollectionViewModel.swift
//  Rotation
//
//  Created by Mack Slevin on 11/17/23.
//

import Foundation
import SwiftData

@Observable
class CollectionViewModel {
    var sortCriteria: CollectionSortCriteria
    
    var useGridView = false
    
    init() {
        sortCriteria = .dateAddedNewest
    }
    
    func sortedEntities(_ musicEntities: [MusicEntity]) -> [MusicEntity] {
        var output: [MusicEntity] = []
        
        switch sortCriteria {
            case .dateAddedNewest:
                output = musicEntities.sorted(by: {
                    $0.dateAdded > $1.dateAdded
                })
            case .dateAddedOldest:
                output = musicEntities.sorted(by: {
                    $0.dateAdded < $1.dateAdded
                })
            default:
                output = musicEntities
        }
        
        return output
    }
}
