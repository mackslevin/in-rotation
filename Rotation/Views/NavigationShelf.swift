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
    
    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .bottom) {
                    
                    ForEach(ViewMode.allCases, id: \.rawValue) { mode in
                        Button {
                            withAnimation {
                                viewMode = mode
                            }
                            
                            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                                withAnimation(
                                    .interactiveSpring(response: 0.75)
                                ) {
                                    shouldShowNavigationShelf.toggle()
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
