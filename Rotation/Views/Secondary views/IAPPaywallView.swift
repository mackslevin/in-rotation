//
//  IAPPaywallView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/21/23.
//

import SwiftUI

struct IAPPaywallView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    EntityLimitReachedView()
                    PremiumUnlockProductView(showExplainer: false)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false))
                                .foregroundStyle(colorScheme == .light ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.2))
                                .shadow(radius: 1)
                        }
                        
                }
            }
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    IAPPaywallView()
        .environmentObject(IAPWrangler())
}
