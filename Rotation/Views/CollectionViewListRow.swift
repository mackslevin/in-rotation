//
//  CollectionViewListRow.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI

struct CollectionViewListRow: View {
    let musicEntity: MusicEntity
    
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationLink {
            MusicEntityDetailView(musicEntity: musicEntity)
        } label: {
            HStack(spacing: 12) {
                VStack {
                    Spacer()
                    Circle()
                        .frame(width: 12)
                        .foregroundStyle(Color.accentColor.gradient)
                        .opacity(musicEntity.played ? 0 : 1)
                    Spacer()
                }
                
                musicEntity.image.resizable().scaledToFit()
                    .padding(musicEntity.imageData == nil ? 10 : 0)
                    .frame(width: 60, height: 60)
                    .background(Color.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                
                VStack(alignment: .leading) {
                    Text(musicEntity.title)
                        .bold()
                    Text(musicEntity.artistName)
                }
            }
            
        }
        .swipeActions(edge: .leading) {
            Button {
                musicEntity.played.toggle()
            } label: {
                if musicEntity.played {
                    Label("Unplayed", systemImage: "play.slash")
                } else {
                    Label("Played", systemImage: "play")
                }
            }
            .tint(Color.accentColor)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                modelContext.delete(musicEntity)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}


#Preview {
    List {
        CollectionViewListRow(musicEntity: Utility.exampleEntity)
    }
    .listStyle(.plain)
    
}
