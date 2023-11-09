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
    
    init(title: String, artistName: String, releaseDate: Date = .distantFuture, numberOfTracks: Int, songTitles: [String], duration: TimeInterval = .zero, imageData: Data? = nil, played: Bool = false) {
        self.title = title
        self.artistName = artistName
        self.releaseDate = releaseDate
        self.numberOfTracks = numberOfTracks
        self.songTitles = songTitles
        self.duration = duration
        self.imageData = imageData
        self.played = played
    }
}
