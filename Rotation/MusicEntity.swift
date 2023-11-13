//
//  MusicEntity.swift
//  Rotation
//
//  Created by Mack Slevin on 11/8/23.
//

import Foundation
import SwiftData

@Observable
class MusicEntity {
    let id = UUID()
    var title: String = ""
    var artistName: String = ""
    var releaseDate: Date = Date.distantFuture
    var numberOfTracks: Int = 0
    var songTitles: [String] = []
    var duration: TimeInterval = .zero
    var imageData: Data? = nil
    var played: Bool = false
    var type: EntityType = .album
    
    var isrc = "" // Cross-platform identifier for songs only 
    var upc = "" // Cross-platform identifier for albums only. (Might not be working for Spotify search.)
    
    init(title: String, artistName: String, releaseDate: Date = .distantFuture, numberOfTracks: Int, songTitles: [String], duration: TimeInterval = .zero, imageData: Data? = nil, played: Bool = false, type: EntityType, isrc: String = "", upc: String = "") {
        self.title = title
        self.artistName = artistName
        self.releaseDate = releaseDate
        self.numberOfTracks = numberOfTracks
        self.songTitles = songTitles
        self.duration = duration
        self.imageData = imageData
        self.played = played
        self.type = type
        self.isrc = isrc
        self.upc = upc
    }
    
    func releaseYear() -> Int? {
        guard self.releaseDate != .distantFuture else { return nil }
        let dateComponents = Calendar.current.dateComponents([.year], from: self.releaseDate)
        return dateComponents.year
    }
}
