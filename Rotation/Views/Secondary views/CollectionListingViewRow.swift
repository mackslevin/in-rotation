//
//  CollectionListingViewRow.swift
//  Rotation
//
//  Created by Mack Slevin on 12/5/23.
//

import SwiftUI

struct CollectionListingViewRow: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var musicEntity: MusicEntity
    
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
                    .frame(width: 80, height: 80)
                    .background(Color.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                
                VStack(alignment: .leading) {
                    Text(musicEntity.title)
                        .font(Font.displayFont(ofSize: 18))
                        .lineLimit(3)
                    Text(musicEntity.artistName)
                        .foregroundStyle(.secondary)
                }
            }
            
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            Button {
                withAnimation {
                    musicEntity.played.toggle()
                }
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
    CollectionListingViewRow(musicEntity: Utility.exampleEntity)
}
