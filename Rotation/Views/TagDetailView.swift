//
//  TagDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData

struct TagDetailView: View {
    @Bindable var tag: Tag
    @State private var isShowingEditTag = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Label(tag.title, systemImage: tag.symbolName)
                        .font(Font.displayFont(ofSize: 22))
                        .fontWeight(.semibold)
                        .foregroundStyle(.tint)
                }
                
                if let musicEntities = tag.musicEntities?.filter({$0.archived == false}), !musicEntities.isEmpty {
                    ScrollView {
                        RecordCoverGridView(musicEntities: musicEntities)
                    }
                } else {
                    ContentUnavailableView("Nothing here yet...", systemImage: "eyes")
                }
                
                Spacer()
            }
            .padding([.horizontal])
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
            .navigationTitle("Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        isShowingEditTag = true
                    } label: {
                        Image(systemName: "slider.vertical.3").resizable().scaledToFit()
                    }
                    .frame(width: 30)
                }
            }
            .sheet(isPresented: $isShowingEditTag) {
                EditTagView(tag: tag)
            }
        }
    }
}

#Preview {
    TagDetailView(tag: Utility.exampleTag)
}
