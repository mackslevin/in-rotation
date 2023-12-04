//
//  CollectionSortCriteria.swift
//  Rotation
//
//  Created by Mack Slevin on 11/17/23.
//

import Foundation

enum CollectionSortCriteria: String, CaseIterable {
    case unplayedFirst = "Unplayed First"
    case unplayedOnly = "Unplayed Only"
    case byTitle = "By Title"
    case byArtist = "By Artist"
    case dateAddedNewest = "Date Added (Newest First)"
    case dateAddedOldest = "Date Added (Oldest First)"
    case byType = "By Type"
    case playedOnly = "Played Only"
}
