import Foundation

enum IAPError: LocalizedError, Equatable {
    case unverified
    case unknownPurchaseState
    case purchasePending
    case system(Error)
    
    var errorDescription: String? {
        switch self {
            case .unverified:
                "The transaction could not be verified"
            case .unknownPurchaseState:
                "The purchase could not be completed"
            case .purchasePending:
                "The purchase is pending. Further action is required before it can be completed."
            case .system(let error):
                error.localizedDescription
        }
    }
    
    static func == (lhs: IAPError, rhs: IAPError) -> Bool {
        switch (lhs, rhs) {
            case (.unverified, .unverified):
                return true
            case (.unknownPurchaseState, .unknownPurchaseState):
                return true
            case (.purchasePending, .purchasePending):
                return true
            case (let .system(lhsError), let .system(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
        }
    }
}
