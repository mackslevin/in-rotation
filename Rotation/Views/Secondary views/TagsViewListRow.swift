//
//  TagsViewListRow.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI
import SwiftData

struct TagsViewListRow: View {
    let tag: Tag
    
    @State private var count = 0
    
    var body: some View {
        NavigationLink {
            TagDetailView(tag: tag)
        } label: {
            VStack(alignment: .leading) {
                HStack {

                    Image(systemName: tag.symbolName).resizable().scaledToFit()
                        .frame(width: 50)
                        .frame(maxHeight: 50)
                        .padding(5)
                        .fontWeight(.light)

                    
                    VStack(alignment: .leading) {
                        Text(tag.title)
                            .font(.displayFont(ofSize: 18))
                        
                        HStack {
                            if let musicEntities = tag.musicEntities, !musicEntities.isEmpty {
                                let last = if musicEntities.count < 5 {
                                    musicEntities.count - 1
                                } else {
                                    4
                                }
                                
                                ForEach(musicEntities[0...last]) { musicEntity in
                                    musicEntity.image
                                        .resizable().scaledToFill()
                                        .frame(width: 20, height: 20)
                                }
                                
                                if musicEntities.count > 5 {
                                    Text("+\(musicEntities.count - 5)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.vertical)
            
        }
        .listRowBackground(Color.clear)
        .onAppear {
            count = tag.musicEntities?.count ?? 0
        }
        .onChange(of: tag.musicEntities) { oldValue, newValue in
            count = newValue?.count ?? 0
        }
    }
}

#Preview {
    List {
        TagsViewListRow(tag: Utility.exampleTag)
        TagsViewListRow(tag: Tag(title: "Hey now", symbolName: "pin", musicEntities: []))
        TagsViewListRow(tag: Tag(title: "Washington", symbolName: "house", musicEntities: []))
    }
    .listStyle(.plain)
    .padding(.top, 100)
    
}
