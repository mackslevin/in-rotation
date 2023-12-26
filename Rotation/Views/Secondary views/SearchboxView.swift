//
//  SearchboxView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/1/23.
//

import SwiftUI

struct SearchboxView: View {
    @Binding var searchText: String
    @Binding var searchTextIntermediary: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Search titles, artist names...", text: $searchTextIntermediary)
                    .onSubmit {
                        withAnimation {
                            searchText = searchTextIntermediary
                            dismiss()
                        }
                    }
                    .padding()
                    .background {
                        if colorScheme == .light {
                            Color.primary.colorInvert()
                        } else {
                            Color.primary.opacity(0.2)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.1) , radius: 4, x: 1, y: 3)
                
                Button("Search") {
                    withAnimation {
                        searchText = searchTextIntermediary
                        dismiss()
                    }
                }.bold()
                Spacer()
            }
            .padding()
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        
    }
}

#Preview {
    SearchboxView(searchText: .constant(""), searchTextIntermediary: .constant(""))
}
