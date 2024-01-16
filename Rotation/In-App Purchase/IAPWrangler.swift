import Foundation
import StoreKit

typealias TransactionListener = Task<Void, Error>

@MainActor
final class IAPWrangler: ObservableObject {
    @Published private(set) var items = [Product]()
    @Published private(set) var iapError: IAPError?
    
    private var transactionListener: TransactionListener?
    
    let myProductIdentifiers =  [
        Utility.premiumUnlockProductID
    ]
    
    init() {
        transactionListener = configureTransactionListener()
        
        Task { [weak self] in
            await self?.retrieveProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    func handlePurchaseCompletion(product: Product, result: Result<Product.PurchaseResult, Error>) async {
        
        switch result {
            case .success(let state):
                switch state {
                    case .pending:
                        iapError = .purchasePending
                    case .success(let verification):
                        switch verification {
                            case .verified(let transaction):
                                await transaction.finish()
                            case .unverified( _, let error):
                                iapError = .system(error)
                        }
                    case .userCancelled:
                        print("^^ user cancelled")
                    @unknown default:
                        iapError = .unknownPurchaseState
                }
                
            case .failure(let error):
                iapError = .system(error)
        }
    }
}

private extension IAPWrangler {
    func configureTransactionListener() -> TransactionListener {
        Task.detached(priority: .background) { @MainActor [weak self] in
            
            for await result in Transaction.updates {
                switch result {
                    case .verified(let transaction):
                        await transaction.finish()
                    case .unverified(_, let error):
                        self?.iapError = .system(error)
                }
            }
            
        }
    }
    
    func retrieveProducts() async {
        do {
            let products = try await Product.products(for: myProductIdentifiers).sorted(by: {$0.price < $1.price})
            items = products
        } catch {
            iapError = .system(error)
        }
    }
}
