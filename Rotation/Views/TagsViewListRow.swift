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
            HStack {
                VStack(alignment: .center) {
                    Spacer()
                    Image(systemName: tag.symbolName).resizable().scaledToFit()
                    Spacer()
                }
                .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(tag.title)
                        .fontWeight(.bold)
                    Text("\(count) items")
                }
            }
        }
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
