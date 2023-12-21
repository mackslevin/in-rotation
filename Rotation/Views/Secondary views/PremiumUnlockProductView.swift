//
//  PremiumUnlockProductView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/21/23.
//

import SwiftUI
import StoreKit

struct PremiumUnlockProductView: View {
    @EnvironmentObject var iapWrangler: IAPWrangler
    
    @State private var alreadyPurchased = false
    @State private var isLoading = false
    
    var body: some View {
        if isLoading {
            ProgressView()
        } else if alreadyPurchased {
            Text("Premium unlocked! Thank you for supporting the app 😊")
        } else {
            ProductView(id: Utility.premiumUnlockProductID)
                .onInAppPurchaseCompletion { product, result in
                    Task {
                        await iapWrangler.handlePurchaseCompletion(product:product, result: result)
                    }
                }
                .currentEntitlementTask(for: Utility.premiumUnlockProductID) { state in
                    
                    switch state {
                        case .loading:
                            isLoading = true
                        case .failure(let error):
                            isLoading = false
                        case .success(let transaction):
                            isLoading = false
                            alreadyPurchased = transaction != nil
                        @unknown default:
                            isLoading = false
                    }
                    
                }
        }
    }
}

#Preview {
    PremiumUnlockProductView()
        .environmentObject(IAPWrangler())
}
