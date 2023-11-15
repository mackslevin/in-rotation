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
    
    var body: some View {
        NavigationStack {
            HStack {
                Text("Tags")
                    .listRowBackground(Color.clear)
                    .font(.largeTitle)
                    .bold()
                    .listRowInsets(EdgeInsets())
                    .foregroundStyle(.tint)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle").resizable().scaledToFit()
                }
                .frame(width: 30)
                .padding([.trailing])
                
                NavigationLink(destination: AddTagView()) {
                    Image(systemName: "plus.circle").resizable().scaledToFit()
                        .frame(width: 30)
                }
            }
            .padding()
            
            List(selection: $selectedTag, content: {
                ForEach(tags) { tag in
                    Text(tag.title)
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

    }
}

#Preview {
    TagsView()
}
