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
    
    @Query(sort: \MusicEntity.dateAdded, order: .reverse) var musicEntities: [MusicEntity]
    
    @State private var isShowingSortingOptions = false
    @State private var viewModel = CollectionViewModel()
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Collection")
                        .font(Font.displayFont(ofSize: 32))
                        .foregroundStyle(.tint)
                    
                    Spacer()
                    
                    Button {
                        isShowingSortingOptions = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle").resizable().scaledToFit()
                    }
                    .frame(width: 30)
                    .padding([.trailing])
                    .popover(isPresented: $isShowingSortingOptions, content: {
                        CollectionSortOptionsView(viewModel: viewModel)
                    })
                    
                    NavigationLink(destination: MusicSearchView()) {
                        Image(systemName: "plus.circle").resizable().scaledToFit()
                            .frame(width: 30)
                    }
                }
                .padding()
                
                if viewModel.useGridView {
                    ScrollView {
                        RecordCoverGridView(musicEntities: viewModel.sortedEntities(musicEntities))
                            .padding()
                    }
                    
                } else {
                    List {
                        Section {
                            ForEach(viewModel.sortedEntities(musicEntities)) { musicEntity in
                                CollectionViewListRow(musicEntity: musicEntity, viewModel: viewModel)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                
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
