//
//  NothingSelectedView.swift
//  Rotation
//
//  Created by Mack Slevin on 7/1/24.
//

import SwiftUI

struct NothingSelectedView: View {
    var body: some View {
        VStack {
            Image(systemName: "circle.dashed")
                .resizable().scaledToFit()
                .frame(width: 80)
            Text("Nothing Selected")
                .font(.displayFont(ofSize: 26))
        }
        .foregroundStyle(.tertiary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
//    NothingSelectedView()
    
    NavigationStack {
        HStack {
            Spacer()
            VStack {
                Spacer()
                NothingSelectedView()
                
                Spacer()
            }
            Spacer()
        }
        .navigationTitle("Something")
        .background { Color.customBG.ignoresSafeArea() }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
