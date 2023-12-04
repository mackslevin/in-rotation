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
                
            case .unplayedFirst:
                var unplayed = musicEntities.filter({!$0.played})
                var played = musicEntities.filter({$0.played})
                
                unplayed = unplayed.sorted(by: {$0.dateAdded > $1.dateAdded})
                played = played.sorted(by: {$0.dateAdded > $1.dateAdded})
                
                output = unplayed + played
            
            case .byTitle:
                output = musicEntities.sorted(by: {$0.title < $1.title})
            
            case .byArtist:
                output = musicEntities.sorted(by: {$0.artistName < $1.artistName})
                
            case .byType:
                output = musicEntities.sorted(by: {$0.type.rawValue < $1.type.rawValue})
                
            case .unplayedOnly:
                output = musicEntities.filter({$0.played == false})
                
            case .playedOnly:
                output = musicEntities.filter({$0.played == true})
            
//            default:
//                output = musicEntities
        }
        
        return output
    }
}
