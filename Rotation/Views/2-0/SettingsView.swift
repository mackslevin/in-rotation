//
//  SettingsView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @AppStorage(StorageKeys.defaultScreen.rawValue) var defaultScreen = DefaultScreen.collection
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appleMusicAuthWrangler) var amAuthWrangler
    @EnvironmentObject var iapWrangler: IAPWrangler
    
    @State private var isShowingWelcomeView = false
    @State private var restorePurchaseError: Error? = nil
    @State private var isShowingRestorePurchaseError = false
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Rectangle()
                    .ignoresSafeArea()
                    .foregroundStyle(Color.customBG)
                
                Form {
                    
                    Section("Apple Music") {
                        HStack {
                            Text("Subscription Status").fontWeight(.medium)
                            Spacer()
                            Text(amAuthWrangler.musicSubscription?.canPlayCatalogContent == true ? "Active" : "Inactive")
                        }
                        HStack {
                            Text("Authorization Status").fontWeight(.medium)
                            Spacer()
                            Text(amAuthWrangler.isAuthorized ? "Authorized" : "Not authoized")
                        }
                        
                        Text("If given authorization, In Rotation can use your active Apple Music subscription to provide extra features, like controlling playback in the Apple Music app and adding to your music library. Authorization can be granted from within the Settings app.")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .italic()
                            .listRowSeparator(.hidden)
                    }
                    
                    Section {
                        Picker("Default screen", selection: $defaultScreen) {
                            ForEach(DefaultScreen.allCases, id: \.rawValue) { screen in
                                Text(screen.rawValue.capitalized)
                                    .tag(screen)
                            }
                        }
                    }
                    
                    Section {
                        PremiumUnlockProductView(showExplainer: true)
                    }
                    
                    Section {
                        Button("Restore Purchase") {
                            Task {
                                do {
                                    try await AppStore.sync()
                                } catch {
                                    restorePurchaseError = error
                                    isShowingRestorePurchaseError = true
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
                .frame(maxWidth: 800, alignment: .center)
                .sheet(isPresented: $isShowingWelcomeView, content: {
                    WelcomeView()
                })
                .alert("Could Not Restore Purchase", isPresented: $isShowingRestorePurchaseError) {
                    Button("OK"){}
                } message: {
                    if let restorePurchaseError {
                        Text(restorePurchaseError.localizedDescription)
                    } else {
                        Text("Please try again.")
                    }
                }
            }
            
            
        }
    }
}

//#Preview {
//    SettingsView()
//}
