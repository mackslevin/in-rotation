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
    
    @MainActor
    func musicEntityFromURL(_ url: URL) async throws -> MusicEntity {
        isLoading = true
        
        let source = try determineSource(ofURL: url)
        
        var newURL: URL? = nil
        if source == .appleMusic {
            newURL = url
        } else if source == .spotify {
            if let linkCollection = try? await ServiceLinksCollection.linkCollection(fromServiceURL: url.absoluteString) {
                let newURLString = linkCollection.linksByPlatform["appleMusic"]?.url
                if let newURLString {
                    newURL = URL(string: newURLString)
                }
            }
        }
        guard let newURL else {
            throw MusicURLWranglerError.unknownSource
        }
        
        // We need to fish the ID out of the URL 🙃
        let urlComponents = URLComponents(url: newURL, resolvingAgainstBaseURL: false)
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
}
