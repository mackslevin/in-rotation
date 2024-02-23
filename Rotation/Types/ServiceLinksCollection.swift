import SwiftUI

struct ServiceLinksCollection: Codable {
    var userCountry: String
    var odesliURL: String
    var linksByPlatform: [String : ServiceLink]
    
    enum CodingKeys: String, CodingKey {
        case userCountry = "userCountry"
        case odesliURL = "pageUrl"
        case linksByPlatform = "linksByPlatform"
    }
    
    static func linkCollection(fromServiceURL url: String) async throws -> ServiceLinksCollection? {
        guard let url = odesliRequestURL(forServiceURL: url) else {
            return nil
        }
        
        if let data = try await odesliDataFromRequestURL(url) {
            return try JSONDecoder().decode(ServiceLinksCollection.self, from: data)
        }
        
        return nil
    }
    
    private static func odesliRequestURL(forServiceURL urlString: String) -> URL? {
        let base = "https://api.song.link/v1-alpha.1/links?url="
        let options = "&userCountry=\(Locale.current.region?.identifier ?? "US")&songIfSingle=true"
        
        print(URL(string: "\(base)\(urlString)\(options)")!)
        return URL(string: "\(base)\(urlString)\(options)")
    }
    
    private static func odesliDataFromRequestURL(_ url: URL) async throws -> Data? {
        let (data, response) = try await URLSession.shared.data(from: url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        guard statusCode == 200 else { print("Bad response: \(statusCode ?? 0)"); return nil }
        
        return data
    }
    
    static func serviceDisplayName(forServiceKey key: String) -> String {
        // This function is meant to take as a parameter a key from the ServiceLinksCollection.linksByPlatform dictionary.
        switch key {
        case "itunes":
            return "iTunes"
        case "appleMusic":
            return "Apple Music"
        case "youtube":
            return "YouTube"
        case "youtubeMusic":
            return "YouTube Music"
        case "googleStore":
            return "Google Play Store"
        case "amazonStore":
            return "Amazon Store"
        case "amazonMusic":
            return "Amazon Music"
        case "soundcloud":
            return "SoundCloud"
        default:
            return key.capitalized
        }
    }

}
