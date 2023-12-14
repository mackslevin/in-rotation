//
//  WelcomeView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/14/23.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    let completion: () -> Void?
    
    var body: some View {
        TabView {
            VStack(spacing: 30) {
                VStack {
                    Image(systemName: "hand.raised.fingers.spread").resizable().scaledToFit()
                        .frame(width: 150)
                        .rotationEffect(.degrees(-30))
                    Text("Welcome to \nIn Rotation")
                        .font(.displayFont(ofSize: 32))
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.accent)
                
                VStack(alignment: .center, spacing: 20) {
                    Text("In Rotation is a to-do list for music.")
                    Text("Get a recommendation from a friend? Run across an interesting album while already listening to another, equally interesting album?")
                    Text("Throw it in the app and build up a collection of new music to explore at your leisure!")
                }
                .frame(width: 300)
                .multilineTextAlignment(.center)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 30) {
                    VStack {
                        Image(systemName: "waveform.badge.plus").resizable().scaledToFit()
                            .frame(width: 100)
                        
                        Text("Two(-ish) ways to add to your collection")
                            .font(.displayFont(ofSize: 32))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(.accent)
                    
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("Bring up the share sheet (\(Image(systemName: "square.and.arrow.up"))) while viewing an album or song in Apple Music or Spotify to quickly add it to your collection.")
                    }
                    .multilineTextAlignment(.center)
                    
                    Image("screenshot-action-extension-share-sheet")
                        .resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                        .shadow(radius: 10)
                        .padding()
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("Alternatively, within this app you can search for music or paste a URL from Apple Music or Spotify")
                    }
                    .multilineTextAlignment(.center)
                    
                    Image("screenshot-music-search")
                        .resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                        .shadow(radius: 10)
                        .padding()
                }
                .padding()
            }
            
            
            
            ScrollView {
                VStack(spacing: 30) {
                    VStack {
                        Image(systemName: "checklist").resizable().scaledToFit()
                            .frame(height: 80)
                        
                        Text("Mark & Manage")
                            .font(.displayFont(ofSize: 32))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(.accent)
                    
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("Once in the app, music can be easily marked as listened/unlistened and quickly open in either Apple Music or Spotify. Apple Music subscribers can also trigger playback directly from the app, as well as easily add items to their Apple Music Library.")
                    }
                    .multilineTextAlignment(.center)
                    
                    Image("screenshot-swipe-mark-played")
                        .resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                        .shadow(radius: 10)
                        .padding()
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("In Rotation also features tagging and notes, which is great for managing larger collections.")
                    }
                    .multilineTextAlignment(.center)
                    
                    Image("screenshot-tags-and-notes")
                        .resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                        .shadow(radius: 10)
                        .padding()
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("You can also easily share link for either Apple Muisc or Spotify so you can recommend to friends on either platform.")
                    }
                    .multilineTextAlignment(.center)
                    
                    Image("screenshot-share-links")
                        .resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
                        .shadow(radius: 10)
                        .padding()
                }
                .padding()
                
            }
            
            VStack(spacing: 30) {
                VStack {
                    Image(systemName: "figure.wave").resizable().scaledToFit()
                        .frame(height: 150)
                    
                    Text("Thanks for downloading In Rotation!")
                        .font(.displayFont(ofSize: 32))
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.accent)
                
                Button {
                    completion()
                    dismiss()
                } label: {
                    Text("Cool, thanks for the lecture. Can I use the app now please?")
                }
                .bold()
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            
        }
        .tabViewStyle(.page)
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .background {
            Utility.customBackground(withColorScheme: colorScheme)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        
    }
}

#Preview {
    WelcomeView(completion: {})
}
