//
//  SearchboxView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/1/23.
//

import SwiftUI

struct SearchboxView: View {
    @Binding var searchText: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Search titles, artist names...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    dismiss()
                }
                
            Button("Done") {
                dismiss()
            }.bold()
            Spacer()
        }
        .padding()
        .background {
            Utility.customBackground(withColorScheme: colorScheme)
        }
    }
}

#Preview {
    SearchboxView(searchText: .constant(""))
}
