//
//  CollectionListingView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/1/23.
//

import SwiftUI
import SwiftData

struct CollectionListingView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<MusicEntity> { return !$0.title.isEmpty }, sort: [SortDescriptor(\MusicEntity.dateAdded)]) var musicEntities: [MusicEntity]
    
    @Binding var searchText: String
    @Binding var showOnlyUnplayed: Bool
    @Binding var tagsForFiltering: [Tag]
    
    var body: some View {
        List {
            ForEach(musicEntities) { musicEntity in
                if musicEntity.title.localizedStandardContains(searchText) || 
                    musicEntity.artistName.localizedStandardContains(searchText) ||
                    searchText.isEmpty 
                {
                    if handleUnplayedFilter(forMusicEntity: musicEntity) && handleTagFiltering(forMusicEntity: musicEntity) {
                        NavigationLink {
                            MusicEntityDetailView(musicEntity: musicEntity)
                        } label: {
                            HStack(spacing: 12) {
                                VStack {
                                    Spacer()
                                    Circle()
                                        .frame(width: 12)
                                        .foregroundStyle(Color.accentColor.gradient)
                                        .opacity(musicEntity.played ? 0 : 1)
                                    Spacer()
                                }
                                
                                musicEntity.image.resizable().scaledToFit()
                                    .padding(musicEntity.imageData == nil ? 10 : 0)
                                    .frame(width: 80, height: 80)
                                    .background(Color.secondary)
                                    .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                                
                                VStack(alignment: .leading) {
                                    Text(musicEntity.title)
                                        .font(Font.displayFont(ofSize: 18))
                                        .lineLimit(3)
                                    Text(musicEntity.artistName)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .leading) {
                            Button {
                                withAnimation {
                                    musicEntity.played.toggle()
                                }
                            } label: {
                                if musicEntity.played {
                                    Label("Unplayed", systemImage: "play.slash")
                                } else {
                                    Label("Played", systemImage: "play")
                                }
                            }
                            .tint(Color.accentColor)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                modelContext.delete(musicEntity)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    
    init(sort: SortDescriptor<MusicEntity>, searchText: Binding<String>, showOnlyUnplayed: Binding<Bool>, tagsForFiltering: Binding<[Tag]>) {
        _musicEntities = Query(sort: [sort])
        _searchText = searchText
        _showOnlyUnplayed = showOnlyUnplayed
        _tagsForFiltering = tagsForFiltering
    }
    
    func handleUnplayedFilter(forMusicEntity musicEntity: MusicEntity) -> Bool {
        if showOnlyUnplayed && musicEntity.played {
            return false
        }
        
        return true
    }
    
    func handleTagFiltering(forMusicEntity musicEntity: MusicEntity) -> Bool {
        if !tagsForFiltering.isEmpty {
            for tag in tagsForFiltering {
                if let existingTags = musicEntity.tags {
                    if existingTags.contains(tag) {
                        return true
                    }
                }
            }
            
            return false
        }
        
        return true
    }
}
//
//#Preview {
//    CollectionListingView(sort: SortDescriptor(\MusicEntity.dateAdded), searchText: "")
//}
