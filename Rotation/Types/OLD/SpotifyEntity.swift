//
//  SpotifyEntity.swift
//  Rotation
//
//  Created by Mack Slevin on 11/21/23.
//

import Foundation

// These objects represent a response from a call to the Spotify Web API endpoints for GET album/track/playlist by ID

struct SpotifyEntity: Codable {
    let type: String
    let uri: String
    let externalIdentifiers: SpotifyExternalIdentifiers?
    let href: String
    let label: String?
    let name: String
    let releaseDate: String?
    let artists: [SpotifyArtist]
    let trackCount: Int?
    let isPlayable: Bool
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case uri = "uri"
        case externalIdentifiers = "external_ids"
        case href = "href"
        case label = "label"
        case name = "name"
        case releaseDate = "release_date"
        case artists = "artists"
        case trackCount = "total_tracks"
        case isPlayable = "is_playable"
    }
}

struct SpotifyExternalIdentifiers: Codable {
    let upc: String?
    let isrc: String?
}

struct SpotifyArtist: Codable {
    let name: String
}

//struct SpotifyTrackCollection: Codable {
//    let items: [SpotifyTrack]
//}


