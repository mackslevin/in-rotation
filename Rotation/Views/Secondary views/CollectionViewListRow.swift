//
//  CollectionViewListRow.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI

struct CollectionViewListRow: View {
    @Bindable var musicEntity: MusicEntity
    @Bindable var viewModel: CollectionViewModel
    
    @Environment(\.modelContext) var modelContext
    @State private var isShowingTagManager = false
    
    @State private var sortingText: String? = nil
    
    var body: some View {
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
                    if let sortingText {
                        Text(sortingText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
                    }
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
            
            Button {
                isShowingTagManager = true
            } label: {
                Label("Tag", systemImage: "tag")
            }
            .tint(Color.accentColor)
        }
        .sheet(isPresented: $isShowingTagManager) {
            TagManagerView(musicEntity: musicEntity)
        }
        .onAppear {
            setSortingText()
        }
        .onChange(of: viewModel.sortCriteria) {
            setSortingText()
        }
    }
    
    func setSortingText() {
        switch viewModel.sortCriteria {
            case .dateAddedNewest, .dateAddedOldest:
                sortingText = "Added: \(musicEntity.dateAdded.formatted())"
            
            case .byType:
                sortingText = Utility.stringForType(musicEntity.type)
                
            default:
                sortingText = nil
        }
    }
}


#Preview {
    List {
        CollectionViewListRow(musicEntity: Utility.exampleEntity, viewModel: CollectionViewModel())
    }
    .listStyle(.plain)
    
}
