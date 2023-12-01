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
    
    @State private var viewModel = CollectionViewModel()
    @State private var sortOrder = SortDescriptor(\MusicEntity.dateAdded, order: .reverse)
    @State private var searchText = ""
    
    @State private var isShowingSearch = false
    
    // something
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Collection")
                        .font(Font.displayFont(ofSize: 32))
                        .foregroundStyle(.tint)
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            isShowingSearch = true
                        } label: {
                            Label("Search...", systemImage: "magnifyingglass")
                        }
                        
                        Menu("Sort") {
                            Picker("Sort & Filter", selection: $sortOrder) {
                                Label("Title", systemImage: "text.quote")
                                    .tag(SortDescriptor(\MusicEntity.title))

                                Label("Artist Name", systemImage: "person.3")
                                    .tag(SortDescriptor(\MusicEntity.artistName))
                                
                                Label("Date Added", systemImage: "calendar.circle")
                                    .tag(SortDescriptor(\MusicEntity.dateAdded, order: .reverse))
                                
                                Label("Release Date", systemImage: "calendar.circle.fill")
                                    .tag(SortDescriptor(\MusicEntity.releaseDate, order: .reverse))
                            }
                            .pickerStyle(.inline)
                        }
                        
                        Menu("Filter") {
                            
                        }
                        
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle").resizable().scaledToFit()
                            .frame(width: 30)
                            .padding([.trailing])
                    }
                    
                    NavigationLink(destination: MusicSearchView()) {
                        Image(systemName: "plus.circle").resizable().scaledToFit()
                            .frame(width: 30)
                    }
                }
                .padding()
                
                VStack {
                    CollectionListingView(sort: sortOrder, searchText: searchText)
                }
                
            }
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .sheet(isPresented: $isShowingSearch, content: {
                SearchboxView(searchText: $searchText)
            })
        }
        
    }
}

#Preview {
    CollectionView()
}
