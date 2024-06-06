//
//  CollectionIndexRow.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI

struct CollectionIndexRow: View {
    let musicEntity: MusicEntity
    
    var body: some View {
        HStack {
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
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

//#Preview {
//    CollectionIndexRow()
//}
