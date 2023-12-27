//
//  MusicURLWrangler.swift
//  Rotation
//
//  Created by Mack Slevin on 11/17/23.
//

import Foundation
import Observation
import MusicKit

enum MusicURLWranglerError: String, Error, Equatable {
    case urlParsing = "Could not parse URL"
    case unknownSource = "Could not determine the URL source to be Spotify or Apple Music. Please try a URL which begins in either \"open.spotify.com\" or \"music.apple.com\""
    case unknownSpotifyType = "The Spotify link was to a resource that does not appear to be an album, track, or playlist."
    case noSpotifyID = "The resource could not be retrieved from the link provided"
    case unsupportedURL = "URL is unsupported"
    case appleMusicAPIError = "There was a problem with the Apple Music API"
    case musicEntityConversionError = "The requested item could not be saved."
}

@Observable
class MusicURLWrangler {
    
    
    
    var isLoading = false
    
    func musicEntityFromURL(_ url: URL) async throws -> MusicEntity {
        isLoading = true
        
        let source = try determineSource(ofURL: url)
        
        if source == .spotify {
            // Check type
            let spotifyType = try determineSpotifyType(fromURL: url)
            let id = try idFromSpotifyURL(url)
            
            switch spotifyType {
                case .song:
                    let track = try await fetchSpotifyTrack(withID: id)
                    isLoading = false
                    return try await musicEntityFromSpotifyTrack(track, spotifyURL: url)
                case .album:
                    let album = try await fetchSpotifyAlbum(withID: id)
                    isLoading = false
                    return try await musicEntityFromSpotifyAlbum(album, spotifyURL: url)
                case .playlist:
                    let playlist = try await fetchSpotifyPlaylist(withID: id)
                    isLoading = false
                    return try await musicEntityFromSpotifyPlaylist(playlist, spotifyURL: url)
            }
        } else if source == .appleMusic {
            // We need to fish the ID out of the URL 🙃
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            var id: String? = nil
            var appleMusicType: EntityType? = nil
            
            // If it's a song, its Apple Music ID should be in query item named `i`. If it's just an album or playlist we can find that ID in the path.
            if let items = urlComponents?.queryItems {
                for item in items {
                    if item.name == "i" {
                        id = item.value
                        appleMusicType = .song
                    }
                }
            }
            if id == nil {
                if let pathBits = urlComponents?.path.components(separatedBy: "/") {
                    if let lastBit = pathBits.last {
                        id = lastBit
                        
                        // Playlist IDs have a specific prefix, album IDs do not
                        appleMusicType = lastBit.hasPrefix("pl.") ? .playlist : .album
                    }
                }
            }
            
            guard let id, let appleMusicType else { throw MusicURLWranglerError.unsupportedURL }
            
            if let musicItem = try await appleMusicItemFromID(id, forType: appleMusicType) {
                if let musicEntity = await AppleMusicSearchWrangler().makeMusicEntity(from: musicItem) {
                    isLoading = false
                    return musicEntity
                } else {
                    isLoading = false
                    throw MusicURLWranglerError.musicEntityConversionError
                }
            } else {
                isLoading = false
                throw MusicURLWranglerError.appleMusicAPIError
            }
        }
        
        isLoading = false
        throw MusicURLWranglerError.unsupportedURL
    }
    
    private func appleMusicItemFromID(_ id: String, forType type: EntityType) async throws -> (any MusicItem)? {
        do {
            switch type {
                case .song:
                    let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(rawValue: id))
                    let response = try await request.response()
                    return response.items.first
                case .album:
                    let request = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: MusicItemID(rawValue: id))
                    let response = try await request.response()
                    return response.items.first
                case .playlist:
                    let request = MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: MusicItemID(rawValue: id))
                    let response = try await request.response()
                    return response.items.first
            }
        } catch {
            throw MusicURLWranglerError.appleMusicAPIError
        }
    }
    
    private func musicEntityFromSpotifyTrack(_ track: SpotifyTrack, spotifyURL: URL) async throws -> MusicEntity {
        
        // Fetch full data for associated album
        
        var album: SpotifyAlbum? = nil
        if let albumStub = track.album {
            album = try await fetchSpotifyAlbum(withID: albumStub.id)
        }
        
        let duration = Double(track.duration / 1000)
        
        var imgData: Data? = nil
        if let imgURLString = album?.images.first?.url, let url = URL(string: imgURLString) {
            let (data, _) = try await URLSession.shared.data(from: url)
            imgData = data
        }
        
        var releaseDate: Date? = nil
        if let album {
            releaseDate = dateFromSpotifyDate(dateString: album.releaseDate)
        }
        
        var artistName: String? = nil
        // Account for possibility of multiple artists
        if track.artists.count > 1 {
            artistName = track.artists.map({$0.name}).joined(separator: " & ")
        } else {
            artistName = track.artists.first?.name
        }
        
        return MusicEntity(
            title: track.name,
            artistName: artistName ?? "",
            releaseDate: releaseDate ?? .distantFuture,
            numberOfTracks: 1,
            songTitles: [track.name],
            duration: duration,
            imageData: imgData,
            type: .song,
            recordLabel: album?.label ?? "",
            isrc: track.externalIDs?.isrc ?? "",
            upc: track.externalIDs?.upc ?? "",
            spotifyURI: track.uri,
            spotifyURLString: spotifyURL.absoluteString,
            spotifyID: track.id
        )
    }
    
    private func musicEntityFromSpotifyAlbum(_ album: SpotifyAlbum, spotifyURL: URL) async throws -> MusicEntity {
        let releaseDate = dateFromSpotifyDate(dateString: album.releaseDate)
        let songTitles = album.tracks.items.map({ $0.name })
        let songDurations = album.tracks.items.map { $0.duration }
        let albumDuration = Double(songDurations.reduce(0, +) / 1000)
        
        var imgData: Data? = nil
        if let imgURLString = album.images.first?.url, let url = URL(string: imgURLString) {
            let (data, _) = try await URLSession.shared.data(from: url)
            imgData = data
        }
        
        var artistName: String? = nil
        // Account for possibility of multiple artists
        if album.artists.count > 1 {
            artistName = album.artists.map({$0.name}).joined(separator: " & ")
        } else {
            artistName = album.artists.first?.name
        }
        
        let musicEntity = MusicEntity(
            title: album.name,
            artistName: artistName ?? "",
            releaseDate: releaseDate ?? .distantFuture,
            numberOfTracks: album.tracks.items.count,
            songTitles: songTitles,
            duration: albumDuration,
            imageData: imgData,
            type: .album,
            recordLabel: album.label,
            upc: album.externalIDs.upc ?? "",
            spotifyURI: album.uri,
            spotifyURLString: spotifyURL.absoluteString,
            spotifyID: album.id
        )
        
        return musicEntity
    }
    
    private func musicEntityFromSpotifyPlaylist(_ playlist: SpotifyPlaylist, spotifyURL: URL) async throws -> MusicEntity {
        let songTitles: [String] = playlist.tracks.items.map({ $0.track.name })
        
        let songDurations: [Int] = playlist.tracks.items.map({ $0.track.duration })
        let playlistDuration = Double(songDurations.reduce(0, +) / 1000)
        
        var imgData: Data? = nil
        if let imgURLString = playlist.images.first?.url, let url = URL(string: imgURLString) {
            let (data, _) = try await URLSession.shared.data(from: url)
            imgData = data
        }
        
        let musicEntity = MusicEntity(
            title: playlist.name,
            artistName: playlist.owner.name,
            numberOfTracks: playlist.tracks.items.count,
            songTitles: songTitles,
            duration: playlistDuration,
            imageData: imgData,
            type: .playlist,
            spotifyURI: playlist.uri,
            spotifyURLString: spotifyURL.absoluteString,
            spotifyID: playlist.id
        )
        
        return musicEntity
    }
    
    private func fetchSpotifyTrack(withID id: String) async throws -> SpotifyTrack {
        let countryCode = Locale.autoupdatingCurrent.region?.identifier ?? ""
        
        guard let requestURL = URL(string: "https://api.spotify.com/v1/tracks/\(id)\(countryCode.isEmpty ? "" : "?market=\(countryCode)")") else {
            throw SpotifyAPIError.badURL
        }
        
        var request = URLRequest(url: requestURL)
        let accessToken = try await SpotifyAPIWrangler().getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard let statusCode, statusCode > 199 && statusCode < 300 else {
            print("^^ Non-200 response: \(response)")
            throw SpotifyAPIError.badResponseStatus
        }
        
        let track = try JSONDecoder().decode(SpotifyTrack.self, from: data)
        
        return track
    }
    
    private func fetchSpotifyAlbum(withID id: String) async throws -> SpotifyAlbum {
        let countryCode = Locale.autoupdatingCurrent.region?.identifier ?? ""
        
        guard let requestURL = URL(string: "https://api.spotify.com/v1/albums/\(id)\(countryCode.isEmpty ? "" : "?market=\(countryCode)")") else {
            throw SpotifyAPIError.badURL
        }
        
        var request = URLRequest(url: requestURL)
        let accessToken = try await SpotifyAPIWrangler().getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard let statusCode, statusCode > 199 && statusCode < 300 else {
            print("^^ Non-200 response: \(response)")
            throw SpotifyAPIError.badResponseStatus
        }
        
        let album = try JSONDecoder().decode(SpotifyAlbum.self, from: data)
        
        return album
    }
    
    private func fetchSpotifyPlaylist(withID id: String) async throws -> SpotifyPlaylist {
        
        let countryCode = Locale.autoupdatingCurrent.region?.identifier ?? ""
        
        guard let requestURL = URL(string: "https://api.spotify.com/v1/playlists/\(id)\(countryCode.isEmpty ? "" : "?market=\(countryCode)")") else {
            throw SpotifyAPIError.badURL
        }
        
        var request = URLRequest(url: requestURL)
        let accessToken = try await SpotifyAPIWrangler().getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard let statusCode, statusCode > 199 && statusCode < 300 else {
            print("^^ Non-200 response: \(response)")
            throw SpotifyAPIError.badResponseStatus
        }
        
        let playlist = try JSONDecoder().decode(SpotifyPlaylist.self, from: data)
        
        return playlist
    }
    
    
    
    private func determineSpotifyType(fromURL url: URL) throws -> EntityType {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let subsequence = components.path.split(separator: "/").first else {
            throw MusicURLWranglerError.urlParsing
        }
        let typeComponent = String(describing: subsequence)
        
        var type: EntityType? = nil
        
        switch typeComponent.lowercased() {
            case "album":
                type = .album
            case "track":
                type = .song
            case "playlist":
                type = .playlist
            default:
                throw MusicURLWranglerError.unknownSpotifyType
        }
        
        if let type {
            return type
        } else {
            throw MusicURLWranglerError.unknownSpotifyType
        }
    }
    
    func determineSource(ofURL url: URL) throws -> URLSource  {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let host = components.host else {
            throw MusicURLWranglerError.urlParsing
        }
        
        if host.contains("spotify.com") {
            return .spotify
        } else if host.contains("apple.com") {
            return .appleMusic
        } else {
            throw MusicURLWranglerError.unknownSource
        }
    }
    
    private func idFromSpotifyURL(_ url: URL) throws -> String {
        var spotifyID: String? = nil
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw SpotifyAPIError.badURL }
        
        let pathParts = components.path.components(separatedBy: "/")
        
        for counter in 0...(pathParts.count - 1) {
            if counter + 1 != pathParts.count {
                for entityType in EntityType.allCases {
                    if pathParts[counter] == entityType.rawValue || pathParts[counter] == "track" {
                        spotifyID = pathParts[counter + 1]
                    }
                }
            }
        }
        
        guard let spotifyID else { throw MusicURLWranglerError.noSpotifyID }
        return spotifyID
    }
    
    func dateFromSpotifyDate(dateString: String) -> Date? {
        // The API returns date strings that are inconsistent. Might be "1999-10-31", or "1999-10", or just "1999".
        
        let dateFormatter = DateFormatter()
        let hyphenCount = dateString.filter { $0 == "-" }.count
        
        switch hyphenCount {
            case 0:
                // Assume it's a 4 digit year value
                dateFormatter.dateFormat = "yyyy"
                return dateFormatter.date(from: dateString)
            case 1:
                // Assume it's something like "1999-10"
                let components = dateString.components(separatedBy: "-")
                guard components.count >= 2 else { return nil }
                if components[1].count == 2 {
                    dateFormatter.dateFormat = "yyyy-MM"
                } else if components[1].count == 1 {
                    dateFormatter.dateFormat = "yyyy-M"
                } else { return nil }
                
                return dateFormatter.date(from: dateString)
            case 2:
                // Assume it's something like "1999-10-31"
                let components = dateString.components(separatedBy: "-")
                guard components.count >= 3 else { return nil }
                
                if components[1].count == 2 {
                    if components[2].count == 2 {
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                    } else if components[2].count == 1 {
                        dateFormatter.dateFormat = "yyyy-MM-d"
                    } else { return nil }
                } else if components[1].count == 1 {
                    if components[2].count == 2 {
                        dateFormatter.dateFormat = "yyyy-M-dd"
                    } else if components[2].count == 1 {
                        dateFormatter.dateFormat = "yyyy-M-d"
                    } else { return nil }
                } else { return nil }
                
                return dateFormatter.date(from: dateString)
            default:
                return nil
        }
    }
}
