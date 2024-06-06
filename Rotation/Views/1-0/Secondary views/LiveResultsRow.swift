//
//  LiveResultsRow.swift
//  Rotation
//
//  Created by Mack Slevin on 12/26/23.
//

import SwiftUI
import MusicKit

struct LiveResultsRow: View {
    let song: Song?
    let album: Album?
    let buttonAction: () -> Void
    
    let thumbnailSize = 120
    
    @State private var thumbnail: Image?
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            HStack {
                if let thumbnail {
                    thumbnail
                        .resizable()
                        .scaledToFill()
                        .frame(width: CGFloat(thumbnailSize) / 2, height: CGFloat(thumbnailSize) / 2)
                        .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true))
                            .foregroundStyle(.secondary)
                        Image(systemName: "music.note")
                            .resizable().scaledToFit().padding()
                    }
                    .frame(width: CGFloat(thumbnailSize) / 2, height: CGFloat(thumbnailSize) / 2)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(title()).bold()
                            .lineLimit(2)
                        if explicit() {
                            Image(systemName: "e.square.fill")
                        }
                    }
                    
                    Text(artist())
                }
                .multilineTextAlignment(.leading)
                .font(.subheadline)
                
                Spacer()
            }
        }
        .task(priority: .background) {
            var url: URL? = nil
            
            if let song {
                url = song.artwork?.url(width: thumbnailSize, height: thumbnailSize)
            } else if let album {
                url = album.artwork?.url(width: thumbnailSize, height: thumbnailSize)
            }
            
            if let url {
                if let (data, _) = try? await URLSession.shared.data(from: url), let uiImage = UIImage(data: data) {
                    thumbnail = Image(uiImage: uiImage)
                }
            }
        }
    }

    func title() -> String {
        if let song {
            return song.title
        } else if let album {
            return album.title
        } else {
            return "N/A"
        }
    }
    
    func artist() -> String {
        if let song {
            return song.artistName
        } else if let album {
            return album.artistName
        } else {
            return "N/A"
        }
    }
    
    func explicit() -> Bool {
        if let song {
            return song.contentRating == .explicit
        } else if let album {
            return album.contentRating == .explicit
        }
        
        return false
    }
}

//#Preview {
//    LiveResultsRow()
//}
