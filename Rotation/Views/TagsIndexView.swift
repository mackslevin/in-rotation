//
//  TagsIndexView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/25/24.
//

import SwiftUI
import SwiftData

struct TagsIndexView: View {
    @Environment(\.modelContext) var modelContext
    @Query var allTags: [Tag]
    @State private var selection: UUID?
    @State private var isShowingAddView = false
    
    var body: some View {
        NavigationSplitView {
            Group {
                if allTags.isEmpty {
                    Button("Add a tag to get started", systemImage: "plus") {
                        isShowingAddView.toggle()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .bold()
                } else {
                    List(selection: $selection) {
                        ForEach(allTags.sorted(by: {$0.title > $1.title})) { tag in
                            HStack {
                                Image(systemName: tag.symbolName)
                                    .frame(width: 25)
                                VStack(alignment: .leading) {
                                    Text(tag.title)
                                        .fontWeight(.semibold)
                                    Text("\(tag.musicEntities?.count ?? 0) \((tag.musicEntities?.count ?? 0) == 1 ? "item" : "items")")
                                        .font(.caption)
                                        .foregroundStyle(selection == tag.id ? .primary : .secondary)
                                        .italic()
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(selection == tag.id ? Color.accentColor : Color.customBG)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    withAnimation {
                                        modelContext.delete(tag)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .background { Color.customBG.ignoresSafeArea() }
            .navigationTitle("Tags")
            .toolbar {
                ToolbarItem(
                    placement: UIDevice.current.userInterfaceIdiom == .pad ? .bottomBar : .topBarTrailing
                ) {
                    Button("Add", systemImage: "plus.circle") {
                        isShowingAddView.toggle()
                    }
                }
            }
            .sheet(isPresented: $isShowingAddView) {
                AddTagView()
            }
        } detail: {
            NavigationStack {
                Group {
                    if let selection, let tag = allTags.first(where: {$0.id == selection}) {
                        TagDetailView(tag: tag)
                    } else {
                        NoTagsSelectedView(shouldShowAddView: $isShowingAddView)
                    }
                        
                }
                .background { Color.customBG.ignoresSafeArea() }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}



//#Preview {
//    TagsIndexView()
//    
//    
//    
////    PrimaryView()
////        .modelContainer(for: MusicEntity.self)
//}
