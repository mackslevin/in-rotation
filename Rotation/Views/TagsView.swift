//
//  TagsView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData

struct TagsView: View {
    @Query var tags: [Tag]
    @State private var selectedTag: Tag?
    @Environment(\.modelContext) var modelContext
    @State private var isShowingAddTag = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Tags")
                        .listRowBackground(Color.clear)
                        .font(Font.displayFont(ofSize: 32))
                        .bold()
                        .foregroundStyle(.tint)
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle").resizable().scaledToFit()
                    }
                    .frame(width: 30)
                    .padding([.trailing])
                    
                    Button {
                        isShowingAddTag = true
                    } label: {
                        Image(systemName: "plus.circle").resizable().scaledToFit()
                            .frame(width: 30)
                    }
                }
                .padding()
                
                List(selection: $selectedTag, content: {
                    ForEach(tags) { tag in
                        TagsViewListRow(tag: tag)
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
                .sheet(isPresented: $isShowingAddTag, content: {
                    AddTagView()
                })
            }
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            
        }

    }
}

#Preview {
    TagsView()
}
