//
//  NotesEditorView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI

struct NotesEditorView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var notesText: String = ""
    @Bindable var musicEntity: MusicEntity
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    if colorScheme == .light {
                        Color.primary.colorInvert()
                    } else {
                        Color.primary.opacity(0.2)
                    }
                    
                    TextEditor(text: $notesText)
                        .scrollContentBackground(.hidden)
                        .padding()
                }
                .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.15) , radius: 5, x: 1, y: 5)
                
                Spacer()
            }
            .padding()
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .onAppear {
                notesText = musicEntity.notes
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        musicEntity.notes = notesText
                        dismiss()
                    }
                    .bold()
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(notesText.isEmpty)
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

//#Preview {
//    NotesEditorView(notesText: .constant(""))
//}
