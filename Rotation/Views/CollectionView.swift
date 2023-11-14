//
//  CollectionView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
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
                
//                Button {
//                    
//                } label: {
//                    Image(systemName: "plus.circle").resizable().scaledToFit()
//                }
//                .frame(width: 30)
                
                NavigationLink(destination: MusicSearchView()) {
                    Image(systemName: "plus.circle").resizable().scaledToFit()
                        .frame(width: 30)
                }
            }
            .padding()
            
            List {
                Section {
                    ForEach(musicEntities) { musicEntity in
                        NavigationLink {
                            Text("Detail view for \(musicEntity.title)")
                        } label: {
                            VStack(alignment: .leading) {
                                Text(musicEntity.title)
                                    .bold()
                                Text(musicEntity.artistName)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        
    }
}

#Preview {
    CollectionView()
}
