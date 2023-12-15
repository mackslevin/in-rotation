//
//  MusicEntity.swift
//  Rotation
//
//  Created by Mack Slevin on 11/8/23.
//

import SwiftUI
import SwiftData

@Model
class MusicEntity {
    let id = UUID()
    let dateAdded = Date.now
    var title: String = ""
    var artistName: String = ""
    var releaseDate: Date = Date.distantFuture
    var numberOfTracks: Int = 0
    var songTitles: [String] = []
    var duration: TimeInterval = TimeInterval.zero
    @Attribute(.externalStorage) var imageData: Data? = nil
    var played: Bool = false
    var type: EntityType = EntityType.album
    var recordLabel: String = ""
    
    var isrc = "" // Cross-platform identifier for songs only 
    var upc = "" // Cross-platform identifier for albums only.
    var appleMusicURLString = ""
    var spotifyURI = ""
    var spotifyURLString = ""
    var spotifyID: String = ""
    var appleMusicID: String = ""
    
    var tags: [Tag]?
    var notes: String = ""
    
    var archived = false
    
    var image: Image {
        if let data = self.imageData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "music.note")
        }
    }
    
    init(title: String, artistName: String, releaseDate: Date = .distantFuture, numberOfTracks: Int, songTitles: [String], duration: TimeInterval = .zero, imageData: Data? = nil, played: Bool = false, type: EntityType, recordLabel: String = "", isrc: String = "", upc: String = "", appleMusicURLString: String = "", spotifyURI: String = "", spotifyURLString: String = "", spotifyID: String = "", appleMusicID: String = "", tags: [Tag]? = [], notes: String = "") {
        self.title = title
        self.artistName = artistName
        self.releaseDate = releaseDate
        self.numberOfTracks = numberOfTracks
        self.songTitles = songTitles
        self.duration = duration
        self.imageData = imageData
        self.played = played
        self.type = type
        self.recordLabel = recordLabel
        self.isrc = isrc
        self.upc = upc
        self.appleMusicURLString = appleMusicURLString
        self.spotifyURI = spotifyURI
        self.spotifyURLString = spotifyURLString
        self.spotifyID = spotifyID
        self.appleMusicID = appleMusicID
        self.tags = tags
        self.notes = notes
        
        self.archived = false
    }
    
    func releaseYear() -> Int? {
        guard self.releaseDate != .distantFuture else { return nil }
        let dateComponents = Calendar.current.dateComponents([.year], from: self.releaseDate)
        return dateComponents.year
    }
}
