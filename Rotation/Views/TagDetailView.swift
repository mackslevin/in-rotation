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
    
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text(tag.title)
                        .listRowBackground(Color.clear)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .listRowInsets(EdgeInsets())
                        .foregroundStyle(.tint)
                    
//                    Spacer()
//                    
//                    Button {
//                        
//                    } label: {
//                        Image(systemName: "square.and.pencil.circle").resizable().scaledToFit()
//                    }
//                    .frame(width: 30)
                }
                
                if let musicEntities = tag.musicEntities, !musicEntities.isEmpty {
                    ScrollView {
                        RecordCoverGridView(musicEntites: musicEntities)
                    }
                } else {
                    ContentUnavailableView("Nothing here yet...", systemImage: "eyes")
                }
                
                Spacer()
            }
            .padding([.horizontal])
            .toolbar {
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.pencil.circle").resizable().scaledToFit()
                    }
                    .frame(width: 30)
                }
            }
        }
    }
}

#Preview {
    TagDetailView(tag: Utility.exampleTag)
}
