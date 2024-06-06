//
//  AddTagView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData

struct AddTagView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var title = ""
    @State private var symbolName = "tag.fill"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                HStack {
                    Text("New Tag")
                        .font(.displayFont(ofSize: 32))
                    Spacer()
                }
                
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)

                
                ScrollView(showsIndicators: true) {
                    SymbolPicker(symbolName: $symbolName)
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
            .padding([.top, .horizontal])
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let newTag = Tag(title: title, symbolName: symbolName)
                        modelContext.insert(newTag)
                        dismiss()
                    }
                    .bold()
                    .disabled(title.isEmpty)
                }
            })
        }
    }
}

#Preview {
    AddTagView()
}
