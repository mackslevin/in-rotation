import Foundation
import MusicKit
import Observation


@Observable
class AppleMusicAuthWrangler {
    var isAuthorized = false
    var musicSubscription: MusicSubscription?
    
    init() {
        Task {
            await getMusicSubscriptionUpdates()
            await requestMusicAuth()
        }
    }
    
    @MainActor
    func requestMusicAuth() async {
        let status = await MusicAuthorization.request()
        switch status {
        case .authorized:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }
    
    @MainActor
    func getMusicSubscriptionUpdates() async {
        for await subscriptionType in MusicSubscription.subscriptionUpdates {
            await MainActor.run {
                musicSubscription = subscriptionType
                print("^^ sub type \(subscriptionType)")
            }
        }
    }
}
