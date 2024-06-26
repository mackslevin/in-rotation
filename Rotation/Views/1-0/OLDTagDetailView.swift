//
//  TagDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI

struct OLDTagDetailView: View {
    @Bindable var tag: Tag
    @State private var isShowingEditTag = false
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedMusicEntity: MusicEntity? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Label(tag.title, systemImage: tag.symbolName)
                        .font(Font.displayFont(ofSize: 22))
                        .fontWeight(.semibold)
                        .foregroundStyle(.tint)
                }
                .padding(.horizontal)
                
                if let musicEntities = tag.musicEntities?.filter({$0.archived == false}), !musicEntities.isEmpty {
                        List {
                            ForEach(musicEntities) { musicEntity in
                                CollectionListingViewRow(musicEntity: musicEntity)
                            }
                        }
                        .listStyle(.plain)
                } else {
                    ContentUnavailableView("Nothing here yet...", systemImage: "eyes")
                }
                
                Spacer()
            }
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
            .onAppear {
                print(tag.musicEntities!)
            }
            .navigationDestination(item: $selectedMusicEntity) { musicEntity in
                OldMusicEntityDetailView(musicEntity: musicEntity)
            }
        }
    }
}

#Preview {
    OLDTagDetailView(tag: Utility.exampleTag)
}
