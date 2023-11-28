//
//  AppleMusicWrangler.swift
//  Rotation
//
//  Created by Mack Slevin on 11/9/23.
//

import SwiftUI
import Observation
import MusicKit

enum AppleMusicWranglerError: String, Error, Equatable {
    case noMatch = "Unable to find a matching item on Apple Music"
    case noRequest = "Request failed"
    case badURL = "Unable to resolve URL"
    case noMatchISRC = "Unable to find a matching song on Apple Music"
    case noMatchUPC = "Unable to find a matching album on Apple Music"
}

@Observable
class AppleMusicWrangler {
    @MainActor
    func openInAppleMusic(_ musicEntity: MusicEntity) async throws {
        
        // If the model already has the URL stored, just open it. Otherwise, conduct another search based on the MusicEntity properties and find a URL from the results.
        
        if !musicEntity.appleMusicURLString.isEmpty {
            print("^^ opening directly")
            if let url = URL(string: musicEntity.appleMusicURLString) {
                await UIApplication.shared.open(url)
            } else {
                throw AppleMusicWranglerError.badURL
            }
        } else {
            print("^^ gonna search")
            let searchTerm = "\(musicEntity.title) \(musicEntity.artistName)"
            var request: MusicCatalogSearchRequest? = nil
            
            switch musicEntity.type {
                case .song:
                    if !musicEntity.isrc.isEmpty {
                        try await openFromISRC(musicEntity.isrc, forMusicEntity: musicEntity)
                        return
                    } else {
                        request = MusicCatalogSearchRequest(term: searchTerm, types: [Song.self])
                    }
                case .album:
                    if !musicEntity.upc.isEmpty {
                        try await openFromUPC(musicEntity.upc, forMusicEntity: musicEntity)
                        return 
                    } else {
                        request = MusicCatalogSearchRequest(term: searchTerm, types: [Album.self])
                    }
                case .playlist:
                    request = MusicCatalogSearchRequest(term: searchTerm, types: [Playlist.self])
            }
            
            print("^^ request \(request as Any)")
            
            guard var request else { throw AppleMusicWranglerError.noRequest }
            
            request.limit = 20
            let response = try await request.response()
            print("^^ got a respoinse")
            var url: URL? = nil
            
            switch musicEntity.type {
                case .song:
                    url = try songMatch(forMusicEntity: musicEntity, fromSongs:  Array<Song>(response.songs)).url
                case .album:
                    url = try albumMatch(forMusicEntity: musicEntity, fromAlbums: Array<Album>(response.albums)).url
                case .playlist:
                    url = try playlistMatch(forMusicEntity: musicEntity, fromPlaylists: Array<Playlist>(response.playlists)).url
            }
            
            if let url {
                await UIApplication.shared.open(url)
            }
        }
    }
    
    @MainActor
    private func openFromISRC(_ isrc: String, forMusicEntity musicEntity: MusicEntity) async throws {
        let request = MusicCatalogResourceRequest<Song>(matching: \.isrc, equalTo: isrc)
        let response = try await request.response()
        if let song = response.items.first {
            if let url = song.url {
                // Add Apple Music data to the model while we're at it. (If we're in this function, the MusicEntity object was almost certainly created from Spotify API data.)
                musicEntity.appleMusicURLString = url.absoluteString
                musicEntity.appleMusicID = song.id.rawValue
                
                await UIApplication.shared.open(url)
            } else {
                throw AppleMusicWranglerError.noMatch
            }
        } else {
            throw AppleMusicWranglerError.noMatchISRC
        }
    }
    
    @MainActor
    private func openFromUPC(_ upc: String, forMusicEntity musicEntity: MusicEntity) async throws {
        let request = MusicCatalogResourceRequest<Album>(matching: \.upc, equalTo: upc)
        let response = try await request.response()
        
        if let album = response.items.first {
            if let url = album.url {
                musicEntity.appleMusicURLString = url.absoluteString
                musicEntity.appleMusicID = album.id.rawValue
                await UIApplication.shared.open(url)
            } else {
                throw AppleMusicWranglerError.noMatch
            }
        } else {
            throw AppleMusicWranglerError.noMatchUPC
        }
    }
    
    private func songMatch(forMusicEntity musicEntity: MusicEntity, fromSongs songs: [Song]) throws -> Song {
        let match = songs.first { song in
            let titleMatch = song.title.lowercased().trimmingCharacters(in: .whitespaces) == musicEntity.title.lowercased().trimmingCharacters(in: .whitespaces)
            
            let artistMatch = song.artistName.lowercased().trimmingCharacters(in: .whitespaces) == musicEntity.artistName.lowercased().trimmingCharacters(in: .whitespaces)
            
            var durationMatch = true
            if let songDuration = song.duration {
                durationMatch = songDuration == musicEntity.duration
            }
            
            return titleMatch && artistMatch && durationMatch
        }
        
        if let match {
            musicEntity.appleMusicURLString = match.url?.absoluteString ?? ""
            return match
        } else {
            throw AppleMusicWranglerError.noMatch
        }
    }
    
    private func albumMatch(forMusicEntity musicEntity: MusicEntity, fromAlbums albums: [Album]) throws -> Album {
        print("^^ albums \(albums)")
        let match = albums.first { album in
            let titleMatch = album.title.lowercased().trimmingCharacters(in: .whitespaces) == musicEntity.title.lowercased().trimmingCharacters(in: .whitespaces)
            print("^^ \(titleMatch)")
            let artistMatch = album.artistName.lowercased().trimmingCharacters(in: .whitespaces) == musicEntity.artistName.lowercased().trimmingCharacters(in: .whitespaces)
            print("^^ \(artistMatch)")
            
            let trackCountMatch = album.trackCount == musicEntity.numberOfTracks
            
            return titleMatch && artistMatch && trackCountMatch
        }
        
        if let match {
            musicEntity.appleMusicURLString = match.url?.absoluteString ?? ""
            return match
        } else {
            throw AppleMusicWranglerError.noMatch
        }
    }
    
    private func playlistMatch(forMusicEntity musicEntity: MusicEntity, fromPlaylists playlists: [Playlist]) throws -> Playlist {
        
        let match = playlists.first { playlist in
            let titleMatch = playlist.name.lowercased().trimmingCharacters(in: .whitespaces) == musicEntity.title.lowercased().trimmingCharacters(in: .whitespaces)
            
            var artistMatch = true
            if let curator = playlist.curatorName {
                artistMatch = curator.lowercased().trimmingCharacters(in: .whitespaces) == musicEntity.artistName.lowercased().trimmingCharacters(in: .whitespaces)
            }
            
            var trackCountMatch = true
            if let playlistCount = playlist.tracks?.count {
                trackCountMatch = playlistCount == musicEntity.numberOfTracks
            }
            
            return trackCountMatch && artistMatch && titleMatch
        }
        
        if let match {
            musicEntity.appleMusicURLString = match.url?.absoluteString ?? ""
            return match
        } else {
            throw AppleMusicWranglerError.noMatch
        }
    }
}
