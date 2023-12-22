//
//  EntityLimitReachedView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/20/23.
//

import SwiftUI

struct EntityLimitReachedView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.lock.fill")
                .resizable().scaledToFit().frame(width: 80)
                .foregroundStyle(Color.accentColor)
            
            Text("Collection Limit Reached")
                .font(.displayFont(ofSize: 28))
                .foregroundStyle(Color.accentColor)
            
            Text("To start, In Rotation limits your collection to \(Utility.maximumFreeEntities) albums or songs. To add more, you can either delete some items or consider making an in-app purchase to unlock unlimited items and help fund further development. ")
                .multilineTextAlignment(.center)
                .fontWeight(.medium)
        }
        .padding()
//        .background { Utility.customBackground(withColorScheme: colorScheme) }
    }
}

#Preview {
    EntityLimitReachedView()
}
