//
//  CollectionIndexRow.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI

struct CollectionIndexRow: View {
    let musicEntity: MusicEntity
    @Binding var selectedID: UUID?
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 12)
                .foregroundStyle(!selected() ? Color.accentColor.gradient : Color.primary.gradient)
                .opacity(musicEntity.played ? 0 : 1)
            
            musicEntity.image
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
            
            VStack(alignment: .leading) {
                Text(musicEntity.title)
                    .font(.displayFont(ofSize: 16))
                    .lineLimit(2)
                
                Text(musicEntity.artistName)
                    .foregroundStyle(selected() ? .primary : .secondary)
                    .lineLimit(1)
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(selected() ? Color.accentColor : Color.customBG)
    }
    
    func selected() -> Bool {
        selectedID == musicEntity.id
    }
}

//#Preview {
//    CollectionIndexRow()
//}
