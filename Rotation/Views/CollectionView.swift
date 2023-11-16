//
//  CollectionView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query var musicEntities: [MusicEntity]
    
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Collection")
                        .font(Font.displayFont(ofSize: 32))
                        .foregroundStyle(.tint)
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle").resizable().scaledToFit()
                    }
                    .frame(width: 30)
                    .padding([.trailing])
                    
                    NavigationLink(destination: MusicSearchView()) {
                        Image(systemName: "plus.circle").resizable().scaledToFit()
                            .frame(width: 30)
                    }
                }
                .padding()
                
                List {
                    Section {
                        ForEach(musicEntities.reversed()) { musicEntity in
                            CollectionViewListRow(musicEntity: musicEntity)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            
        }
        
    }
}

#Preview {
    CollectionView()
}
