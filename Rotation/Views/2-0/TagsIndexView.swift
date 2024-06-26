//
//  TagsIndexView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/25/24.
//

import SwiftUI
import SwiftData

struct TagsIndexView: View {
    @Query var allTags: [Tag]
    
    @State private var selection: UUID?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(allTags.sorted(by: {$0.title > $1.title})) { tag in
                    HStack {
                        Image(systemName: tag.symbolName)
                            .frame(width: 25)
                        VStack(alignment: .leading) {
                            Text(tag.title)
                            Text("\(tag.musicEntities?.count ?? 0) \((tag.musicEntities?.count ?? 0) == 1 ? "item" : "items")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .italic()
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(selection == tag.id ? Color.accentColor : Color.customBG)
                }
            }
            
            .listStyle(.plain)
            .background { Color.customBG.ignoresSafeArea() }
            .navigationTitle("Tags")
        } detail: {
            NavigationStack {
                Group {
                    if let selection, let tag = allTags.first(where: {$0.id == selection}) {
                        Text(tag.title)
                    } else {
                        Text("Nothing")
                    }
                        
                }
                .background { Color.customBG.ignoresSafeArea() }
            }
        }
    }
}



#Preview {
    TagsIndexView()
    
    
    
//    PrimaryView()
//        .modelContainer(for: MusicEntity.self)
}
