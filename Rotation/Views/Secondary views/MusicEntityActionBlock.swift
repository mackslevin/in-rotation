//
//  MusicEntityActionBlock.swift
//  Rotation
//
//  Created by Mack Slevin on 11/15/23.
//

import SwiftUI
import MediaPlayer
import MusicKit

struct MusicEntityActionBlock: View {
    @Bindable var musicEntity: MusicEntity
    @State private var amWrangler = AppleMusicWrangler()
    @State private var played = false
    @Environment(\.appleMusicAuthWrangler) var amAuthWrangler
    
    let actionIconSize: CGFloat = 36
    
    @State var isShowingErrorAlert: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            HStack {
                VStack {
                    AppleMusicPlayButton(musicEntity: musicEntity)
                        .font(.system(size: actionIconSize, weight: .bold))
                        .disabled(appleMusicPlaybackDisabled())
                    Text("Apple Music")
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundStyle(appleMusicPlaybackDisabled() ? .secondary : .primary)
                }
                .frame(width: 75)
                
                Spacer()
                
                Menu {
                    ForEach(Array(musicEntity.serviceLinks.keys.sorted()), id: \.self) { key in
                        if let urlString = musicEntity.serviceLinks[key], let url = URL(string: urlString) {
                            Link(ServiceLinksCollection.serviceDisplayName(forServiceKey: key), destination: url)
                        }
                    }
                } label: {
                    VStack {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: actionIconSize, weight: .bold))
                        Text("Open")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                    }
                    .frame(width: 75)
                }
                
                Spacer()
                    
                VStack {
                    Image(systemName: played ? "circle.fill" : "circle")
                        .font(.system(size: actionIconSize, weight: .bold))
                        .foregroundStyle(played ? Color.primary : Color.accentColor)
                    Text(played ? "Played" : "Unplayed")
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                }
                .frame(width: 75)
                .onTapGesture {
                    withAnimation {
                        played.toggle()
                    }
                }
            }
            .padding()
            .tint(.primary)
        }
        .background {
            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false))
                .foregroundStyle(.regularMaterial)
        }
        .onAppear {
            played = musicEntity.played
        }
        .onChange(of: played) { _, newValue in
            musicEntity.played = newValue
        }
        .alert(errorMessage ?? "Something went wrong. Please try again.", isPresented: $isShowingErrorAlert) { Button("OK"){} }
        
    }
    
    func appleMusicPlaybackDisabled() -> Bool {
        if let sub = amAuthWrangler.musicSubscription, sub.canPlayCatalogContent {
            return false
        }
        
        return true
    }
}

#Preview {
    VStack {
        Spacer()
        MusicEntityActionBlock(musicEntity: Utility.exampleEntity)
        Spacer()
    }
    .padding()
    
}
