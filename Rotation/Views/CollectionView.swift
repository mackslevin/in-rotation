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
    @Query var musicEntities: [MusicEntity]
    
    
    var body: some View {
        NavigationStack {
            HStack {
                Text("Collection")
                    .listRowBackground(Color.clear)
                    .font(.largeTitle)
                    .bold()
                    .listRowInsets(EdgeInsets())
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
                    .onDelete(perform: { indexSet in
                        if let index = indexSet.first {
                            withAnimation { modelContext.delete(musicEntities[index]) }
                        }
                    })
                }
            }
            .listStyle(.plain)
        }
        
    }
}

#Preview {
    CollectionView()
}
