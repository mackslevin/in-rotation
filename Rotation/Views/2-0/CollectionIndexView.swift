//
//  CollectionIndexView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI
import SwiftData

struct CollectionIndexView: View {
    @Query var musicEntities: [MusicEntity]
    @State var selectedEntityID: UUID?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedEntityID) {
                ForEach(musicEntities) { musicEntity in
                    Text(musicEntity.title)
                }
            }
        } detail: {
            NavigationStack {
                Text("Detail")
            }
        }

    }
}

#Preview {
    CollectionIndexView()
}
