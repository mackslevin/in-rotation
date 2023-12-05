//
//  MusicEntityHeadlineBlock.swift
//  Rotation
//
//  Created by Mack Slevin on 12/4/23.
//

import SwiftUI

struct MusicEntityHeadlineBlock: View {
    @Bindable var musicEntity: MusicEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(musicEntity.title)
                    .font(.displayFont(ofSize: 28))
                    
                HStack(alignment: .bottom) {
                    Text("by \(musicEntity.artistName)")
                        .multilineTextAlignment(.leading)
                    
                    if let tags = musicEntity.tags, !tags.isEmpty {
                        
                        Spacer()
                        Group {
                            let last = tags.count < 4 ? tags.count - 1 : 3
                            
                            ForEach(tags[0...last]) { tag in
                                Image(systemName: tag.symbolName)
                                    .font(.caption)
                            }
                            
                            if tags.count > 4 {
                                let howManyMoreTags = tags.count - 4
                                Text("+\(howManyMoreTags)")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(.secondary)
                    } else {
                        Spacer()
                    }
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

#Preview {
    MusicEntityHeadlineBlock(musicEntity: Utility.exampleEntity)
}
