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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                HStack {
                    Text("Edit Tag")
                        .font(.displayFont(ofSize: 32))
                    Spacer()
                }
                TextField("Title", text: $tag.title)
                    .textFieldStyle(.roundedBorder)
                
                ScrollView(showsIndicators: true) {
                    SymbolPicker(symbolName: $tag.symbolName)
                }
            }
            .padding()
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                    .disabled(tag.title.isEmpty)
                }
            }
            
        }
    }
}

#Preview {
    EditTagView(tag: Utility.exampleTag)
}
