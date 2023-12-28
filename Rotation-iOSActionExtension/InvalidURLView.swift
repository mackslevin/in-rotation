//
//  InvalidURLView.swift
//  Rotation-iOSActionExtension
//
//  Created by Mack Slevin on 12/26/23.
//

import SwiftUI

struct InvalidURLView: View {
    let url: URL?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Unable to import 😞")
                .font(Font.displayFont(ofSize: 32))
                .foregroundStyle(.tint)
            
            if let url {
                Text("The following URL could not be matched with a valid Apple Music or Spotify item:")
                Text(url.absoluteString)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.secondary)
                
                
                Text("Please try again with a URL that looks more like one of these:")
                Text("\("https://open.spotify.com/album/6gWz09raxjmq1EMIPcbnFy?si=GOAEo3tfSWS01OH7yHAI2g")")
                    .fontDesign(.monospaced)
                    .foregroundStyle(.secondary)
                Text("\("https://music.apple.com/us/album/hard-to-be/718735084?i=718735089")")
                    .fontDesign(.monospaced)
                    .foregroundStyle(.secondary)
            } else {
                Text("This application is not providing a valid URL")
            }
        }
    }
}

//#Preview {
//    InvalidURLView()
//}
