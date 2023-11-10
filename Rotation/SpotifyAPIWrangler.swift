//
//  SpotifyAPIWrangler.swift
//  Rotation
//
//  Created by Mack Slevin on 11/9/23.
//

import SwiftUI
import Observation

@Observable
class SpotifyAPIWrangler {
    private let clientID = "e3d47c96c2384fabb9bf112ac641575c"
    private let clientSecret = "25a5e9010204460bb8c70af1b78278ee"
    
    func getAccessToken() async throws {
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
            
            print("^^ Received access token: \(UserDefaults.standard.string(forKey: "spotifyAccessToken"))")
            return
        }
        
        print("^^ Existing token: \(accessToken as Any) updated \(UserDefaults.standard.value(forKey: "spotifyTokenLastUpdated") as? TimeInterval)")
    }
}
