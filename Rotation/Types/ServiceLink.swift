import SwiftUI

struct ServiceLink: Codable {
    var country: String = ""
    var url: String = ""
    var entityUniqueId: String = ""
    var nativeAppUriMobile: String? = nil
    var nativeAppUriDesktop: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case country
        case url
        case entityUniqueId
        case nativeAppUriMobile
        case nativeAppUriDesktop
    }
    
//    init(country: String, url: String = "", entityUniqueId: String = "", nativeAppUriMobile: String? = nil, nativeAppUriDesktop: String? = nil) {
//        self.country = country
//        self.url = url
//        self.entityUniqueId = entityUniqueId
//        self.nativeAppUriMobile = nativeAppUriMobile
//        self.nativeAppUriDesktop = nativeAppUriDesktop
//    }
}
