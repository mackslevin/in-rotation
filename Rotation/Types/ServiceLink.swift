import SwiftUI

struct ServiceLink: Codable {
    var country: String = ""
    var url: String = ""
    var entityUniqueId: String = ""
    var nativeAppUriMobile: String? = nil
    var nativeAppUriDesktop: String? = nil
}
