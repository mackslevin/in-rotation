//
//  TagTogglerView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/16/23.
//

import SwiftUI
import SwiftData

struct TagTogglerView: View {
    @Binding var selectedTags: [Tag]
    @Query var allTags: [Tag]
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isShowingAddTag = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("\(selectedTags.count) selected")
                        .foregroundStyle(selectedTags.count == 0 ? .secondary : .primary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                        ForEach(allTags) { tag in
                            if selectedTags.contains(tag) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true))
                                        .foregroundStyle(Color.accentColor)
                                    Label(tag.title, systemImage: tag.symbolName)
                                        .padding()
                                        .foregroundStyle(.white)
                                        .fontWeight(.semibold)
                                }
                                .onTapGesture {
                                    toggleTag(tag)
                                }
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true))
                                        .foregroundStyle(Color.secondary)
                                    RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true))
                                        .foregroundStyle(.primary).colorInvert()
                                        .padding(1)
                                    Label(tag.title, systemImage: tag.symbolName)
                                        .padding()
                                        .foregroundStyle(.secondary)
                                        .fontWeight(.semibold)
                                }
                                .onTapGesture {
                                    toggleTag(tag)
                                }
                            }
                        }
                    })
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Tags")
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar() {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("New tag...") {
                        isShowingAddTag = true
                    }
                }
            }
            .sheet(isPresented: $isShowingAddTag, content: {
                AddTagView()
            })
            
        }
        
        
    }
    
    func toggleTag(_ tag: Tag) {
        if selectedTags.contains(where: {$0.id == tag.id}) {
            print("^^ contains tag")
//            withAnimation {
                selectedTags.removeAll(where: {$0.id == tag.id})
//            }
        } else {
            print("^^ doesn't contain tag")
//            withAnimation {
                selectedTags.append(tag)
//            }
        }
    }
}

#Preview {
    
        TagTogglerView(selectedTags: .constant([Utility.exampleTag, Utility.exampleTag, Utility.exampleTag, Utility.exampleTag, Utility.exampleTag]))
    
    
    
}
