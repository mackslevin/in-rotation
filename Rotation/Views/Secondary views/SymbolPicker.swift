//
//  SymbolPicker.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI

struct SymbolPicker: View {
    @Binding var symbolName: String
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16, content: {
            
            ForEach(Utility.sfSymbols, id: \.self) { sfSymbol in
                Image(systemName: sfSymbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .onTapGesture {
                        symbolName = sfSymbol
                    }
                    .foregroundStyle(sfSymbol == symbolName ? Color.accentColor : .secondary)
            }
        })
    }
}

//#Preview {
//    SymbolPicker()
//}
