//
//  SpotifyPlaylist.swift
//  Rotation
//
//  Created by Mack Slevin on 11/21/23.
//

import Foundation

struct SpotifyPlaylist: Codable {
    let id: String
    let name: String
    let uri: String
    let images: [SpotifyImage]
    let type: String
    let owner: SpotifyPlaylistOwner
    let tracks: SpotifyPlaylistTrackCollection
}

struct SpotifyImage: Codable {
    let height: Int?
    let width: Int?
    let url: String
}

struct SpotifyPlaylistOwner: Codable {
    let name: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case name = "display_name"
        case id = "id"
    }
}

struct SpotifyPlaylistTrackCollection: Codable {
    let items: [SpotifyPlaylistTrackWrapper]
}

struct SpotifyPlaylistTrackWrapper: Codable {
    let track: SpotifyTrack
}

struct SpotifyTrack: Codable {
    let name: String
    let duration: Int // Will be in milliseconds
    let id: String
    let artists: [SpotifyArtist]
    let album: SpotifyAlbumStub?
    let externalIDs: SpotifyExternalIDsWrapper?
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case duration = "duration_ms"
        case id = "id"
        case artists = "artists"
        case album = "album"
        case externalIDs = "external_ids"
        case uri = "uri"
    }
}

struct SpotifyAlbumStub: Codable {
    // Sometimes when retrieving other items like Tracks, there will be an Album property that does not contain all the properties of a proper SpotifyAlbum. We can use the ID here to make a request for the full album data
    let name: String
    let id: String
}

struct SpotifyAlbum: Codable {
    let id: String
    let name: String
    let uri: String
    let label: String
    let artists: [SpotifyArtist]
    let images: [SpotifyImage]
    let tracks: SpotifyAlbumTrackCollection
    let type: String
    let externalIDs: SpotifyExternalIDsWrapper
    let releaseDate: String
    let releaseDatePrecision: String
    let totalTracks: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case uri = "uri"
        case label = "label"
        case artists = "artists"
        case images = "images"
        case tracks = "tracks"
        case type = "type"
        case externalIDs = "external_ids"
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case totalTracks = "total_tracks"
    }
}

struct SpotifyArtist: Codable {
    let id: String
    let name: String
}

struct SpotifyAlbumTrackCollection: Codable {
    let items: [SpotifyTrack]
}

struct SpotifyExternalIDsWrapper: Codable {
    let isrc: String?
    let ean: String?
    let upc: String?
}
