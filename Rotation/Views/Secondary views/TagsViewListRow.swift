//
//  TagsViewListRow.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI
import SwiftData

struct TagsViewListRow: View {
    @State var tag: Tag
    
    @State private var musicEntities: [MusicEntity] = []
    
    @State private var count = 0
    
    var body: some View {
        NavigationLink {
            TagDetailView(tag: tag)
        } label: {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 12) {

                    Image(systemName: tag.symbolName)/*.resizable().scaledToFit()*/
                        .font(.body)
                        .frame(width: 30, height: 30)
                        .padding(8)
                        .fontWeight(.medium)
                        .background {
                            Circle()
                                .foregroundStyle(.secondary)
                                .opacity(0.5)
                        }
                        .foregroundStyle(.tint)
                        

                    
                    VStack(alignment: .leading) {
                        Text(tag.title)
                            .font(.displayFont(ofSize: 18))
                        
                        HStack {
                            let musicEntities = musicEntities.filter({$0.archived == false})
                            if !musicEntities.isEmpty {
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
            if let tagEntities = tag.musicEntities {
                musicEntities = tagEntities
                count = musicEntities.count
            }
        }
        .onChange(of: tag.musicEntities) { oldValue, newValue in
//            count = newValue?.count ?? 0
            
            if let tagEntities = newValue {
                musicEntities = tagEntities
                count = musicEntities.count
            } else {
                musicEntities = []
                count = 0
            }
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
