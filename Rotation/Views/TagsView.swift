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
//    @State private var selectedTag: Tag?
    @Environment(\.modelContext) var modelContext
    @State private var isShowingAddTag = false
    @Environment(\.colorScheme) var colorScheme
    @State private var sortOrder = SortDescriptor(\Tag.dateCreated, order: .reverse)
    
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
                    
                    Menu {
                        Picker("Sort Tags", selection: $sortOrder) {
                            Label("Date Added", systemImage: "calendar.circle")
                                .tag(SortDescriptor<Tag>(\Tag.dateCreated, order: .reverse))
                            Label("Name, A-Z", systemImage: "a.circle")
                                .tag(SortDescriptor<Tag>(\Tag.title, order: .forward))
                            Label("Name, Z-A", systemImage: "z.circle")
                                .tag(SortDescriptor<Tag>(\Tag.title, order: .reverse))
                        }
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
                
                TagsListingView(sort: sortOrder)
                
            }
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .sheet(isPresented: $isShowingAddTag, content: {
                AddTagView()
            })
            
        }

    }
}

#Preview {
    TagsView()
}
