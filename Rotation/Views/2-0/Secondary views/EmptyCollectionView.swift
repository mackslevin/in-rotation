//
//  EmptyCollectionView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/14/24.
//

import SwiftUI

struct EmptyCollectionView: View {
    @Binding var vm: CollectionIndexViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "eyes")
                .resizable().scaledToFit()
                .frame(width: 50)
            Text("Nothing here yet...")
                .font(.displayFont(ofSize: 18))
            Button {
                vm.shouldShowAddView.toggle()
            } label: {
                Label("Add to Collection", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .foregroundStyle(
                Color.customBG
            )
            .bold()
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .padding(.top)
    }
}

//#Preview {
//    EmptyCollectionView()
//}
