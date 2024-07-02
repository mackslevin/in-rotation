//
//  CollectionSort.swift
//  Rotation
//
//  Created by Mack Slevin on 7/2/24.
//

import Foundation

enum CollectionSort: String, Identifiable, CaseIterable {
    var id: String { self.rawValue }
    case dateAdded = "Date Added"
    case alphabeticalByTitle = "Alphabetical by Title"
    case alphabeticalByArtist = "Alphabetical by Artist"
    
    var systemImage: String {
        switch self {
        case .dateAdded:
            return "calendar"
        case .alphabeticalByTitle:
            return "textformat"
        case .alphabeticalByArtist:
            return "music.mic"
        }
    }
}
