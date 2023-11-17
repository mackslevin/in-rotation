//
//  SpotifySearchResults.swift
//  Rotation
//
//  Created by Mack Slevin on 11/10/23.
//

import Foundation

struct SpotifySearchResults: Decodable {
    let tracks: SpotifySearchResultsTrack?
    let albums: SpotifySearchResultsAlbum?
    
    enum CodingKeys: String, CodingKey {
        case tracks = "tracks"
        case albums = "albums"
    }
}

struct SpotifySearchResultsTrack: Decodable {
    let items: [SpotifySearchResultsItem]
}

struct SpotifySearchResultsAlbum: Decodable {
    let items: [SpotifySearchResultsAlbumItem]
}

struct SpotifySearchResultsItem: Decodable {
    let id: String
    let uri: String
}

struct SpotifySearchResultsAlbumItem: Decodable {
    let id: String
    let totalTracks: Int?
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case totalTracks = "total_tracks"
        case uri = "uri"
    }
}
