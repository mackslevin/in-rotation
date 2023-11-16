//
//  RecordCoverGridView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI

struct RecordCoverGridView: View {
    let musicEntites: [MusicEntity]
    
    @Environment(\.horizontalSizeClass) var horizontalSize
    
    @State private var columnCount = 2
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: columnCount), alignment: .center, spacing: 5) {
            ForEach(musicEntites) { musicEntity in
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
