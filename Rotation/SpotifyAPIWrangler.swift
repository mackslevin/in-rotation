//
//  SpotifyAPIWrangler.swift
//  Rotation
//
//  Created by Mack Slevin on 11/9/23.
//

import SwiftUI
import Observation

enum SpotifyAPIError: String, Error, CaseIterable {
    case badQuery = "Could not construct search query"
    case badURL = "Could not construct a URL for the request"
    case badAccessToken = "Bad (or no) access token"
    case badResponseStatus = "The server request was unsuccessful"
    case countryCodeUnavailable = "Could not get user country code"
    case decodingError = "Could not decode search results"
    case noResults = "No search results"
}

@Observable
class SpotifyAPIWrangler {
    private let clientID = "e3d47c96c2384fabb9bf112ac641575c"
    private let clientSecret = "25a5e9010204460bb8c70af1b78278ee"
    
    private func getAccessToken() async throws -> String {
        struct TokenResponse: Decodable {
            let accessToken: String
            
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
            }
        }
        
        let accessToken = UserDefaults.standard.string(forKey: "spotifyAccessToken")
        let tokenLastUpdated = UserDefaults.standard.value(forKey: "spotifyTokenLastUpdated")
        let tokenInterval: TimeInterval? = tokenLastUpdated as? TimeInterval
        
        // Grab a new access token only if we never got one or if the one we have was last updated over an hour ago
        if accessToken == nil || Date.now.timeIntervalSinceReferenceDate - (tokenInterval ?? 0) >= 3600 {
            var urlRequest = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let requestBody = "grant_type=client_credentials&client_id=\(clientID)&client_secret=\(clientSecret)".data(using: .utf8)
            urlRequest.httpBody = requestBody
            
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let decoder = JSONDecoder()
            let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
            
            UserDefaults.standard.setValue(tokenResponse.accessToken, forKey: "spotifyAccessToken")
            UserDefaults.standard.setValue(Date.now.timeIntervalSinceReferenceDate, forKey: "spotifyTokenLastUpdated")
        }
        
        if let token = UserDefaults.standard.string(forKey: "spotifyAccessToken"), !token.isEmpty {
            return token
        } else {
            throw SpotifyAPIError.badAccessToken
        }
    }
    
    func openInSpotify(_ musicEntity: MusicEntity) async throws {
        let spotifyURI = try await findMatch(forMusicEntity: musicEntity)
        
        let url = URL(string: "https://api.spotify.com/v1/me/player/play")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let accessToken = try await getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let body: Data = try JSONSerialization.data(withJSONObject: [
            "context_uri": "spotify:album:5ht7ItJgpBH7W6vJ5BqpPr"
        ], options: [])
        request.httpBody = body
    }
    
    private func findMatch(forMusicEntity musicEntity: MusicEntity) async throws -> String {
        // The string returned by this function will be the URI of a Spotify catalog item
        
        var urlComponents = URLComponents(string: "https://api.spotify.com/v1/search")
        var resultsLimit = "1"

        // Adjust the request parameters depending on entity type
        switch musicEntity.type {
            case .song:
                let type = URLQueryItem(name: "type", value: "track")
                let query = URLQueryItem(name: "query", value: "track:\(musicEntity.title) artist:\(musicEntity.artistName)\(musicEntity.isrc.isEmpty ? "" : " isrc:\(musicEntity.isrc)")")
                urlComponents?.queryItems = [query, type]

            case .album:
                let type = URLQueryItem(name: "type", value: "album")
                let query = URLQueryItem(name: "query", value: "\(musicEntity.title) \(musicEntity.artistName)")
                urlComponents?.queryItems = [query, type]
                resultsLimit = "5"
            
            default: throw SpotifyAPIError.badQuery
        }
        
        // Finish putting together request
        if let code = Locale.autoupdatingCurrent.region?.identifier {
            urlComponents?.queryItems?.append(URLQueryItem(name: "market", value: code))
        } else {
            throw SpotifyAPIError.countryCodeUnavailable
        }
        urlComponents?.queryItems?.append(URLQueryItem(name: "limit", value: resultsLimit))
        guard let url = urlComponents?.url else { throw SpotifyAPIError.badURL }
        var request = URLRequest(url: url)
        let accessToken = try await getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Fetch and decode data
        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard let statusCode, statusCode > 199 && statusCode < 300 else {
            throw SpotifyAPIError.badResponseStatus
        }
        guard let results = try? JSONDecoder().decode(SpotifySearchResults.self, from: data) else {
            throw SpotifyAPIError.decodingError
        }
        
        // Get Spotify ID from search results
        switch musicEntity.type {
            case .song:
                if let uri = results.tracks?.items.first?.uri {
                    return uri
                }
                throw SpotifyAPIError.noResults
            case .album:
                if let albums = results.albums?.items {
                    for album in albums {
                        // If possible, only return an album with matching number of tracks
                        if let trackCount = album.totalTracks, trackCount == musicEntity.numberOfTracks {
                            return album.uri
                        }
                    }
                    if let uri = albums.first?.uri {
                        // Alright, well at least return something
                        return uri
                    }
                }
                
                throw SpotifyAPIError.noResults
            default:
                throw SpotifyAPIError.noResults
        }
    }
}
