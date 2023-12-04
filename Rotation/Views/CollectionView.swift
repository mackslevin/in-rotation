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
    
//    @State private var viewModel = CollectionViewModel()
    @State private var sortOrder = SortDescriptor(\MusicEntity.dateAdded, order: .reverse)
    
    @State private var searchText = ""
    @State private var searchTextIntermediary = ""
    
    @State private var isShowingSearch = false
    
    
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
                        Image(systemName: "ellipsis.circle").resizable().scaledToFit()
                            .frame(width: 30)
                            .padding([.trailing], 10)
                    }
                    
                    NavigationLink(destination: MusicSearchView()) {
                        Image(systemName: "plus.circle").resizable().scaledToFit()
                            .frame(width: 30)
                    }
                }
                .padding()
                
                if !searchText.isEmpty {
                    HStack {
                        Text("Search results for \"\(searchText)\"")
                            .italic().foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            searchText = ""
                        } label: {
                            Text("Clear")
                        }.buttonStyle(.bordered)
                    }
                    .font(.caption)
                    .padding()
                    
                }
                
                CollectionListingView(sort: sortOrder, searchText: $searchText)
                
                
            }
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .sheet(isPresented: $isShowingSearch, content: {
                SearchboxView(searchText: $searchText, searchTextIntermediary: $searchTextIntermediary)
            })
        }
        
    }
}

#Preview {
    CollectionView()
}
