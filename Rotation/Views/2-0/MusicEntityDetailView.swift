//
//  MusicEntityDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI
import SwiftData

struct MusicEntityDetailView: View {
    @Bindable var musicEntity: MusicEntity
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(musicEntity.title)
                .italic()
            Text(musicEntity.artistName)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
//    MusicEntityDetailView()
    PrimaryView()
}
