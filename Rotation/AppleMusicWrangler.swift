//
//  AppleMusicWrangler.swift
//  Rotation
//
//  Created by Mack Slevin on 11/9/23.
//

import SwiftUI
import Observation
import MusicKit

enum AppleMusicWranglerError: Error, Equatable {
    case noMatch, noRequest
}

@Observable
class AppleMusicWrangler {
    @MainActor
    func openInAppleMusic(_ musicEntity: MusicEntity) async throws {
        let searchTerm = "\(musicEntity.title) \(musicEntity.artistName)"
        var request: MusicCatalogSearchRequest? = nil
        
        switch musicEntity.type {
            case .song:
                request = MusicCatalogSearchRequest(term: searchTerm, types: [Song.self])
            case .album:
                request = MusicCatalogSearchRequest(term: searchTerm, types: [Album.self])
            case .playlist:
                request = MusicCatalogSearchRequest(term: searchTerm, types: [Playlist.self])
        }
        
        guard var request else { throw AppleMusicWranglerError.noRequest }
        
        request.limit = 20
        let response = try await request.response()
        
        var url: URL? = nil
        
        switch musicEntity.type {
            case .song:
                url = try songMatch(forMusicEntity: musicEntity, fromSongs:  [Song](response.songs)).url
            case .album:
                url = try albumMatch(forMusicEntity: musicEntity, fromAlbums: [Album](response.albums)).url
            case .playlist:
                url = try playlistMatch(forMusicEntity: musicEntity, fromPlaylists: [Playlist](response.playlists)).url
        }
        
        if let url {
            
            await UIApplication.shared.open(url)
            
            
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
            
            var dateMatch = true
            if let songDate = song.releaseDate {
                let cal = Calendar.current
                dateMatch = cal.component(.year, from: songDate) == cal.component(.year, from: musicEntity.releaseDate) && cal.component(.month, from: songDate) == cal.component(.month, from: musicEntity.releaseDate) && cal.component(.day, from: songDate) == cal.component(.day, from: musicEntity.releaseDate)
            }
            
            return titleMatch && artistMatch && dateMatch && durationMatch
        }
        
        if let match {
            return match
        } else {
            throw AppleMusicWranglerError.noMatch
        }
    }
    
    private func albumMatch(forMusicEntity musicEntity: MusicEntity, fromAlbums albums: [Album]) throws -> Album {
        
        let match = albums.first { album in
            let titleMatch = album.title.lowercased().trimmingCharacters(in: .whitespaces) == musicEntity.title.lowercased().trimmingCharacters(in: .whitespaces)
            
            let artistMatch = album.artistName.lowercased().trimmingCharacters(in: .whitespaces) == musicEntity.artistName.lowercased().trimmingCharacters(in: .whitespaces)
            
            var dateMatch = true
            if let albumDate = album.releaseDate {
                let cal = Calendar.current
                dateMatch = cal.component(.year, from: albumDate) == cal.component(.year, from: musicEntity.releaseDate) && cal.component(.month, from: albumDate) == cal.component(.month, from: musicEntity.releaseDate) && cal.component(.day, from: albumDate) == cal.component(.day, from: musicEntity.releaseDate)
            }
            
            let trackCountMatch = album.trackCount == musicEntity.numberOfTracks
            
            
            return titleMatch && artistMatch && dateMatch && trackCountMatch
        }
        
        if let match {
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
            
            var dateMatch = true
            if let playlistDate = playlist.lastModifiedDate {
                let cal = Calendar.current
                dateMatch = cal.component(.year, from: playlistDate) == cal.component(.year, from: musicEntity.releaseDate) && cal.component(.month, from: playlistDate) == cal.component(.month, from: musicEntity.releaseDate) && cal.component(.day, from: playlistDate) == cal.component(.day, from: musicEntity.releaseDate)
            }
            
            var trackCountMatch = true
            if let playlistCount = playlist.tracks?.count {
                trackCountMatch = playlistCount == musicEntity.numberOfTracks
            }
            
            return trackCountMatch && dateMatch && artistMatch && titleMatch
        }
        
        if let match {
            return match
        } else {
            throw AppleMusicWranglerError.noMatch
        }
    }
}
