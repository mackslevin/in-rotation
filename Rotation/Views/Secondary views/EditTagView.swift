//
//  EditTagView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI

struct EditTagView: View {
    @Bindable var tag: Tag
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                TextField("Title", text: $tag.title)
                    .textFieldStyle(.roundedBorder)
                
                ScrollView(showsIndicators: true) {
                    SymbolPicker(symbolName: $tag.symbolName)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
            .navigationTitle("Edit Tag")
        }
    }
}

#Preview {
    EditTagView(tag: Utility.exampleTag)
}
