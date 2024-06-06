//
//  RecordCoverGridView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI
import SwiftData

struct RecordCoverGridView: View {
    @Bindable var tag: Tag
    @State var musicEntities: [MusicEntity]
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.horizontalSizeClass) var horizontalSize
    @Environment(\.dismiss) var dismiss
    
    @State private var columnCount = 2
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: columnCount), alignment: .center, spacing: 5) {
            ForEach(musicEntities) { musicEntity in
                NavigationLink {
                    MusicEntityDetailView(musicEntity: musicEntity)
                } label: {
                    musicEntity.image.resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                        .overlay {
                            VStack {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .foregroundStyle(.regularMaterial)
                                            .frame(width: 14)
                                        
                                        Circle()
                                            .frame(width: 12)
                                            .foregroundStyle(Color.accentColor.gradient)
                                    }
                                    .opacity(musicEntity.played ? 0 : 1)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .padding(5)
                        }
                }
                .contextMenu(menuItems: {
                    Button {
                        withAnimation {
                            musicEntity.played.toggle()
                        }
                    } label: {
                        if musicEntity.played {
                            Label("Mark Unplayed", systemImage: "play.slash")
                        } else {
                            Label("Mark Played", systemImage: "play")
                        }
                    }
                    .tint(Color.accentColor)
                    
                    Button {
                        withAnimation {
                            musicEntity.archived.toggle()
                            print("^^ \(musicEntity.archived ? "just archived" : "just unarchived")")
                        }
                    } label: {
                        Label("\(musicEntity.archived ? "Un-archive" : "Archive")", systemImage: "archivebox")
                    }
                    
                    Button(role: .destructive) {
                        withAnimation {
                            tag.musicEntities?.removeAll(where: {$0.id == musicEntity.id})
                            modelContext.delete(musicEntity)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                })
            }
        }
        .onAppear {
            if horizontalSize == .regular {
                columnCount = 3
            } else {
                columnCount = 2
            }
        }
    }
}

//#Preview {
//    RecordCoverGridView()
//}
