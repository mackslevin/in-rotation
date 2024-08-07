////
////  SpotifyAPIWrangler.swift
////  Rotation
////
////  Created by Mack Slevin on 11/9/23.
////
//
//import SwiftUI
//import Observation
//
//@Observable
//class SpotifyAPIWrangler {
//    private let clientID = "e3d47c96c2384fabb9bf112ac641575c"
//    private let clientSecret = "25a5e9010204460bb8c70af1b78278ee"
//    
//    func getAccessToken() async throws -> String {
//        struct TokenResponse: Decodable {
//            let accessToken: String
//            
//            enum CodingKeys: String, CodingKey {
//                case accessToken = "access_token"
//            }
//        }
//        
//        let accessToken = UserDefaults.standard.string(forKey: "spotifyAccessToken")
//        let tokenLastUpdated = UserDefaults.standard.value(forKey: "spotifyTokenLastUpdated")
//        let tokenInterval: TimeInterval? = tokenLastUpdated as? TimeInterval
//        
//        // Grab a new access token only if we never got one or if the one we have was last updated over an hour ago
//        if accessToken == nil || Date.now.timeIntervalSinceReferenceDate - (tokenInterval ?? 0) >= 3600 {
//            var urlRequest = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
//            urlRequest.httpMethod = "POST"
//            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//            let requestBody = "grant_type=client_credentials&client_id=\(clientID)&client_secret=\(clientSecret)".data(using: .utf8)
//            urlRequest.httpBody = requestBody
//            
//            let (data, _) = try await URLSession.shared.data(for: urlRequest)
//            let decoder = JSONDecoder()
//            let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
//            
//            UserDefaults.standard.setValue(tokenResponse.accessToken, forKey: "spotifyAccessToken")
//            UserDefaults.standard.setValue(Date.now.timeIntervalSinceReferenceDate, forKey: "spotifyTokenLastUpdated")
//        }
//        
//        if let token = UserDefaults.standard.string(forKey: "spotifyAccessToken"), !token.isEmpty {
//            print("^^ token \(token)")
//            return token
//        } else {
//            throw SpotifyAPIError.badAccessToken
//        }
//    }
//    
////    func openInSpotify(_ musicEntity: MusicEntity) async throws {
////        if !musicEntity.spotifyURLString.isEmpty {
////            let urlString = musicEntity.spotifyURLString
////            await MainActor.run {
////                open(URL(string: urlString)!)
////            }
////        } else {
////            let urlString = try await findMatch(forMusicEntity: musicEntity)
////            musicEntity.spotifyURLString = urlString
////            await MainActor.run {
////                open(URL(string: urlString)!)
////            }
////        }
////    }
//    
//    
//    private func open(_ url: URL) {
//        #if ACTIONEXTENSION
//        print("It's the actionextension")
//        #else
//        UIApplication.shared.open(url)
//        #endif
//    }
//    
//    func findMatch(forMusicEntity musicEntity: MusicEntity) async throws -> String {
//        // The string returned by this function will be the URL of a Spotify catalog item
//        var urlComponents = URLComponents(string: "https://api.spotify.com/v1/search")
//        let resultsLimit = "1"
//
//        // Adjust the request parameters depending on entity type
//        switch musicEntity.type {
//            case .song:
//                let type = URLQueryItem(name: "type", value: "track")
//                var query: URLQueryItem? = nil
//                if !musicEntity.isrc.isEmpty {
//                    query = URLQueryItem(name: "query", value: "isrc:\(musicEntity.isrc)")
//                } else {
//                    query = URLQueryItem(name: "query", value: "track:\(musicEntity.title) artist:\(musicEntity.artistName)")
//                }
//                urlComponents?.queryItems = [query!, type]
//            case .album:
//                let type = URLQueryItem(name: "type", value: "album")
//                let query = URLQueryItem(name: "query", value: "upc:\(musicEntity.upc)")
//                print("^^ music ent upc \(musicEntity.upc)")
//                urlComponents?.queryItems = [query, type]
//            
//            default: throw SpotifyAPIError.badQuery
//        }
//        
//        // Finish putting together request
//        if let code = Locale.autoupdatingCurrent.region?.identifier {
//            urlComponents?.queryItems?.append(URLQueryItem(name: "market", value: code))
//        } else {
//            throw SpotifyAPIError.countryCodeUnavailable
//        }
//        urlComponents?.queryItems?.append(URLQueryItem(name: "limit", value: resultsLimit))
//        guard let url = urlComponents?.url else { throw SpotifyAPIError.badURL }
//        print("^^ req url \(url.absoluteString)")
//        var request = URLRequest(url: url)
//        let accessToken = try await getAccessToken()
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        
//        // Fetch and decode data
//        let (data, response) = try await URLSession.shared.data(for: request)
//        let statusCode = (response as? HTTPURLResponse)?.statusCode
//        guard let statusCode, statusCode > 199 && statusCode < 300 else {
//            throw SpotifyAPIError.badResponseStatus
//        }
//        guard let results = try? JSONDecoder().decode(SpotifySearchResults.self, from: data) else {
//            throw SpotifyAPIError.decodingError
//        }
//        
//        // Get and save various pieces of Spotify info from search results (so we can avoid this process next time), return URL string
//        switch musicEntity.type {
//            case .song:
//                if let result = results.tracks?.items.first, let url = result.externalURLs?.spotify {
//                    musicEntity.spotifyURLString = url
//                    musicEntity.spotifyURI = result.uri
//                    musicEntity.spotifyID = result.id
//                    
//                    return url
//                } else { print("^^ no url!!") }
//                
//                throw SpotifyAPIError.noResults
//            case .album:
//                if let result = results.albums?.items.first, let url = result.externalURLs?.spotify {
//                    musicEntity.spotifyURLString = url
//                    musicEntity.spotifyURI = result.uri
//                    musicEntity.spotifyID = result.id
//                    
//                    return url
//                } else {
//                    let fuzzyResult = try? await fuzzyAlbumSearch(musicEntity)
//                    if let fuzzyResult, !fuzzyResult.isEmpty {
//                        return fuzzyResult
//                    }
//                }
//                
//                throw SpotifyAPIError.noResults
//            default:
//                throw SpotifyAPIError.noResults
//        }
//    }
//    
//    private func fuzzyAlbumSearch(_ musicEntity: MusicEntity) async throws -> String {
//        // This method is a fallback for if the UPC-based search we try initially doesn't turn up any results. Here we'll search by album and artist name instead and return the result (if any) with a matching track count.
//        // The return value is a Spotify URL string.
//        guard musicEntity.type == .album else { throw SpotifyAPIError.incorrectType }
//        
//        var urlComponents = URLComponents(string: "https://api.spotify.com/v1/search")
//        let resultsLimit = "5"
//        let type = URLQueryItem(name: "type", value: "album")
//        let query = URLQueryItem(name: "query", value: "\(musicEntity.title) \(musicEntity.artistName)")
//        urlComponents?.queryItems = [query, type]
//        
//        if let code = Locale.autoupdatingCurrent.region?.identifier {
//            urlComponents?.queryItems?.append(URLQueryItem(name: "market", value: code))
//        } else {
//            throw SpotifyAPIError.countryCodeUnavailable
//        }
//        urlComponents?.queryItems?.append(URLQueryItem(name: "limit", value: resultsLimit))
//        guard let url = urlComponents?.url else { throw SpotifyAPIError.badURL }
//        var request = URLRequest(url: url)
//        let accessToken = try await getAccessToken()
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        let statusCode = (response as? HTTPURLResponse)?.statusCode
//        guard let statusCode, statusCode > 199 && statusCode < 300 else {
//            throw SpotifyAPIError.badResponseStatus
//        }
//        guard let results = try? JSONDecoder().decode(SpotifySearchResults.self, from: data) else {
//            throw SpotifyAPIError.decodingError
//        }
//        
//        if let albums = results.albums?.items {
//            for album in albums {
//                // If possible, only return an album with matching number of tracks
//                if let trackCount = album.totalTracks, trackCount == musicEntity.numberOfTracks {
//                    
//                    let urlString = album.externalURLs?.spotify ?? ""
//                    
//                    musicEntity.spotifyURI = album.uri
//                    musicEntity.spotifyURLString = urlString
//                    
//                    if !urlString.isEmpty {
//                        return urlString
//                    }
//                }
//            }
//            if let ulrString = albums.first?.externalURLs?.spotify, let uri = albums.first?.uri {
//                // Alright, well at least return something
//                musicEntity.spotifyURI = uri
//                musicEntity.spotifyURLString = ulrString
//                return ulrString
//            }
//        }
//        
//        throw SpotifyAPIError.noResults
//    }
//}
