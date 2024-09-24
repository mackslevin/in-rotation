//
//  NavigationShelf.swift
//  Rotation
//
//  Created by Mack Slevin on 9/21/24.
//

import SwiftUI

struct NavigationShelf: View {
    @Binding var shouldShowNavigationShelf: Bool
    @Binding var viewMode: ViewMode
    @AppStorage(StorageKeys.alwaysShowTabBar.rawValue) var alwaysShowTabBar: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // Add upper border only if tab bar is always showing. It doesn't animate well if placed here, so when the bar is set to show/hide, the border is part of the toggler view.
                if alwaysShowTabBar {
                    Rectangle().foregroundStyle(.primary)
                        .frame(height: 1)
                        .opacity(0.1)
                }
                
                HStack(alignment: .bottom) {
                    
                    ForEach(ViewMode.allCases, id: \.rawValue) { mode in
                        Button {
                            withAnimation {
                                viewMode = mode
                            }
                            
                            if !alwaysShowTabBar {
                                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                                    withAnimation(
                                        .interactiveSpring(response: 0.75)
                                    ) {
                                        shouldShowNavigationShelf.toggle()
                                    }
                                }
                            }
                        } label: {
                            VStack(spacing: 4) {
                                mode.sfSymbol
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text(mode.rawValue)
                                    .font(Font.displayFont(ofSize: 10))
                                    .textCase(.uppercase)
                                    .fontWeight(.medium)
                            }
                        }
                        .tint(viewMode == mode ? .accentColor : .secondary)
                        
                        if mode != ViewMode.allCases.last {
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: 500)
                .padding(.horizontal, 30)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .frame(height: shouldShowNavigationShelf ? 90 : 0)
        .transition(.slide)
        .offset(y: shouldShowNavigationShelf ? 0 : 90)
    }
}

//#Preview {
//    NavigationShelf()
//}
