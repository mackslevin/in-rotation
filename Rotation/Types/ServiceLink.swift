import SwiftUI

struct ServiceLink: Codable {
    let country: String
    let url: String
    let entityUniqueId: String
    let nativeAppUriMobile: String?
    let nativeAppUriDesktop: String?
}
