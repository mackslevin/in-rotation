//
//  PremiumUnlockProductView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/21/23.
//

import SwiftUI
import StoreKit

struct PremiumUnlockProductView: View {
    let showExplainer: Bool
    
    @EnvironmentObject var iapWrangler: IAPWrangler
    
    @State private var alreadyPurchased = false
    @State private var isLoading = false
    
    @State private var entitlementError: Error? = nil
    @State private var isShowingError = false
    @State private var isShowingIAPError = false
    
    var body: some View {
        if isLoading {
            HStack {
                Spacer(); ProgressView(); Spacer()
            }
        } else if alreadyPurchased {
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "fireworks")
                        .symbolRenderingMode(.hierarchical)
                        .resizable().scaledToFit()
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 80)
                    Text("Premium Unlocked!")
                        .font(.displayFont(ofSize: 28))
                        .foregroundStyle(.tint)
                    Text("Thank you for supporting the app 😊")
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
        } else {
            VStack(alignment: .leading) {
                ProductView(id: Utility.premiumUnlockProductID) {
                    Image(systemName: "fireworks")
                        .symbolRenderingMode(.hierarchical)
                        .resizable().scaledToFit()
                        .foregroundStyle(Color.accentColor)
                }
                .onInAppPurchaseStart(perform: { _ in
                    isLoading = true
                })
                .onInAppPurchaseCompletion { product, result in
                    isLoading = false
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
                            entitlementError = error
                            isShowingError = true
                        case .success(let transaction):
                            isLoading = false
                            alreadyPurchased = transaction != nil
                        @unknown default:
                            isLoading = false
                    }
                    
                }
                .alert("Error", isPresented: $isShowingError) {
                } message: {
                    if let entitlementError {
                        Text(entitlementError.localizedDescription)
                    } else {
                        Text("Entitlements failed to load.")
                    }
                }
                .onChange(of: iapWrangler.iapError) { oldValue, newValue in
                    if newValue != nil {
                        isShowingIAPError = true
                    }
                }
                .alert(isPresented: $isShowingIAPError, error: iapWrangler.iapError) {}
                
                if showExplainer {
                    Text("To start, In Rotation limits your collection to \(Utility.maximumFreeEntities) albums or songs. To add more, you can either delete some items or consider making an in-app purchase to unlock unlimited items and help fund further development.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
                
            }
            
        }
    }
}

#Preview {
    PremiumUnlockProductView(showExplainer: false)
        .environmentObject(IAPWrangler())
}
