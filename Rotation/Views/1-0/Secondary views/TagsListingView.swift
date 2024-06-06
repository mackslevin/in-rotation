//
//  TagsListingView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/12/23.
//

import SwiftUI
import SwiftData

struct TagsListingView: View {
    @Environment(\.modelContext) var modelContext
    @Query var tags: [Tag]
    @State private var selectedTag: Tag?
    
    var body: some View {
        List(selection: $selectedTag, content: {
            ForEach(tags) { tag in
                TagsViewListRow(tag: tag)
                    .contextMenu {
                        Button(role: .destructive) {
                            withAnimation {
                                modelContext.delete(tag)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .onDelete(perform: { indexSet in
                if let index = indexSet.first {
                    withAnimation {
                        modelContext.delete(tags[index])
                    }
                }
            })
        })
        .listStyle(.plain)
    }
    
    init(sort: SortDescriptor<Tag>) {
        _tags = Query(sort: [sort])
    }
}

//#Preview {
//    TagsListingView()
//}
