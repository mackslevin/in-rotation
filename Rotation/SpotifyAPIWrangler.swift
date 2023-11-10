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
            
            print("^^ Received access token: \(String(describing: UserDefaults.standard.string(forKey: "spotifyAccessToken")))")
            
        }
        
        print("^^ Existing token: \(accessToken as Any) updated \(String(describing: UserDefaults.standard.value(forKey: "spotifyTokenLastUpdated") as? TimeInterval))")
        
        if let token = UserDefaults.standard.string(forKey: "spotifyAccessToken"), !token.isEmpty {
            return token
        } else {
            throw SpotifyAPIError.badAccessToken
        }
    }
    
    func openInSpotify(_ musicEntity: MusicEntity) async throws {
        
//        try await getAccessToken()
        let _ = try await findMatch(forMusicEntity: musicEntity)
    }
    
    private func findMatch(forMusicEntity musicEntity: MusicEntity) async throws -> URL {
        
        
        
        
        let endpoint = "https://api.spotify.com/v1/search?"
        var query = ""
        var type = ""
        var market = ""
        if let code = Locale.autoupdatingCurrent.region?.identifier {
            market = "market=\(code)"
        }
        
        
        
        switch musicEntity.type {
            case .song:
                type = "type=track"
                if let encodedQuery = "q=track:\(musicEntity.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) artist:\(musicEntity.artistName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)\(musicEntity.isrc.isEmpty ? "" : " isrc=\(musicEntity.isrc.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    query = encodedQuery
                } else {
                    throw SpotifyAPIError.badQuery
                }
            case .album:
                type = "type=album"
            case .playlist:
                type = "type=playlist"
        }
        
        let urlString = "\(endpoint)\(query)&\(type)&\(market)"
        guard let url = URL(string: urlString) else {
            throw SpotifyAPIError.badURL
        }
        
        var request = URLRequest(url: url)
        let accessToken = try await getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard let statusCode, statusCode > 199 && statusCode < 300 else {
            throw SpotifyAPIError.badResponseStatus
        }
        
        print("^^ response: \(response)")
        print("^^ data: \(String(data: data, encoding: .utf8)!)")
        
        
        
        return URL(string: "https://google.com")!
    }
}
