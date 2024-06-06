//
//  MusicEntityDetailsBlock.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI

struct MusicEntityDetailsBlock: View {
    let musicEntity: MusicEntity
    
    var body: some View {
        VStack(spacing: 12) {
            if musicEntity.releaseDate != .distantFuture {
                HStack {
                    Text("Released")
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(Utility.prettyDate(musicEntity.releaseDate))
                }
            }
            
            HStack {
                Text("Tracks")
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(musicEntity.numberOfTracks)")
            }
            
            HStack {
                Text("Duration")
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Utility.formattedTimeInterval(musicEntity.duration))
            }
            
            if !musicEntity.recordLabel.isEmpty {
                HStack(alignment: .top) {
                    Text("Label")
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(musicEntity.recordLabel)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false))
                .foregroundStyle(.regularMaterial)
        }
    }
}

var eljghsfdljg = Utility.exampleEntity
#Preview {
    VStack {
        Spacer()
        MusicEntityDetailsBlock(musicEntity: eljghsfdljg)
        Spacer()
    }
    
}
