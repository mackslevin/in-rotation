//
//  LittleTagGrid.swift
//  Rotation
//
//  Created by Mack Slevin on 11/16/23.
//

import SwiftUI

struct LittleTagGrid: View {
    let tags: [Tag]
    var body: some View {
        if tags.count >= 3 {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(tags) { tag in
                    ZStack {
                        Capsule()
                            .foregroundStyle(Color.accentColor)
                        Text(tag.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                    
                }
            }
            
        } else {
            HStack {
                Spacer()
                ForEach(tags) { tag in
                    
                    Text(tag.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            Capsule()
                                .foregroundStyle(Color.accentColor)
                        }
                    
                }
                Spacer()
            }
        }
    }
}
//
//#Preview {
//    LittleTagGrid()
//}
