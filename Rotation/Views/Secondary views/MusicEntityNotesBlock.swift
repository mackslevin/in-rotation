//
//  MusicEntityNotesBlock.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI

struct MusicEntityNotesBlock: View {
    @Bindable var musicEntity: MusicEntity
    
    @State private var isShowingEditor = false
    
    var body: some View {
        VStack {
            if musicEntity.notes.isEmpty {
                HStack {
                    Spacer()
                    Button {
                        isShowingEditor = true
                    } label: {
                        Label("Add Notes", systemImage: "plus.circle")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Notes")
                            .fontWeight(.semibold)
                        Spacer()
                        
                        Button {
                            isShowingEditor = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                    
                    Text(musicEntity.notes)
                }
                .padding()
            }
        }
        .background {
            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false))
                .foregroundStyle(.regularMaterial)
        }
        .sheet(isPresented: $isShowingEditor, content: {
            NotesEditorView(musicEntity: musicEntity)
        })
    }
}

#Preview {
    VStack {
        Spacer()
        MusicEntityNotesBlock(musicEntity: Utility.exampleEntity)
        Spacer()
    }
    
}
