//
//  CollectionSortCriteria.swift
//  Rotation
//
//  Created by Mack Slevin on 11/17/23.
//

import Foundation

enum CollectionSortCriteria: String, CaseIterable, Codable {
    case byTitle = "By Title"
    case byArtist = "By Artist"
    case dateAdded = "Date Added"
    case releaseDate = "Release Date"
}
