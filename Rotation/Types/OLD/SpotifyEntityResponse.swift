//
//  SpotifyEntityResponse.swift
//  Rotation
//
//  Created by Mack Slevin on 11/20/23.
//

import Foundation


//struct SpotifyEntityResponse: Codable {
//    let type: String
//    let uri: String
//    let externalIdentifiers: SpotifyExternalIdentifiers?
//    let href: String
//    let label: String?
//    let name: String
//    let releaseDate: String?
//    let artists: [SpotifyArtist]
//    let trackCount: Int?
//    let isPlayable: Bool
//    
//    enum CodingKeys: String, CodingKey {
//        case type = "type"
//        case uri = "uri"
//        case externalIdentifiers = "external_ids"
//        case href = "href"
//        case label = "label"
//        case name = "name"
//        case releaseDate = "release_date"
//        case artists = "artists"
//        case trackCount = "total_tracks"
//        case isPlayable = "is_playable"
//    }
//}
//
//struct SpotifyExternalIdentifiers: Codable {
//    let upc: String?
//    let isrc: String?
//}
//
//struct SpotifyArtist: Codable {
//    let name: String
//}
//
//struct SpotifyTrackCollection: Codable {
//    let items: [SpotifyTrack]
//}
//
//struct SpotifyTrack: Codable {
//    let name: String
//    let duration: Int
//    
//    enum CodingKeys: String, CodingKey {
//        case name = "name"
//        case duration = "duration_ms"
//    }
//}
