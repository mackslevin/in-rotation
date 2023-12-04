//
//  TagManagerView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData

struct TagManagerView: View {
    @Bindable var musicEntity: MusicEntity
    @Environment(\.dismiss) var dismiss
    @Query var tags: [Tag]
    @State private var isShowingAddTag = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Applied Tags") {
                    if let tags = musicEntity.tags, !tags.isEmpty {
                        ForEach(tags) { tag in
                            Text(tag.title).bold()
                                .onTapGesture {
                                    withAnimation {
                                        musicEntity.tags?.removeAll(where: {$0.id == tag.id})
                                        
                                        tag.musicEntities?.removeAll(where: {$0.id == musicEntity.id}) // This should be redundant. A workaround to tag not updating entity removal promptly.
                                    }
                                }
                        }
                    } else {
                        Text("None yet").italic().foregroundStyle(.secondary)
                    }
                }
                .listRowSeparator(.hidden)
                
                Section("Other Tags") {
                    ForEach(tags) { tag in
                        if let entityTags = musicEntity.tags, !entityTags.contains(tag) {
                            Text(tag.title).foregroundStyle(.secondary)
                                .onTapGesture {
                                    
                                    withAnimation {
                                        musicEntity.tags?.append(tag)
                                    }
                                    
                                    
                                }
                        }
                    }
                }
                .listRowSeparator(.hidden)
                
                HStack {
                    Spacer()
                    Button("Create New Tag...") {
                        isShowingAddTag = true
                    }
                    .bold()
                    .foregroundStyle(.tint)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .padding(.vertical)
                
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
            .sheet(isPresented: $isShowingAddTag) {
                AddTagView()
            }
        }
        
    }
}

#Preview {
    TagManagerView(musicEntity: Utility.exampleEntity)
}
