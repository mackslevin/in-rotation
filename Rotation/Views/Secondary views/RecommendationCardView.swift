//
//  RecommendationCardView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/7/23.
//

import SwiftUI

struct RecommendationCardView: View {
    let recEntity: RecommendationEntity
    let viewModel: ExploreViewModel
    let completion: (Bool) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var offset: CGSize = .zero
    @State private var cardOverlayColor = Color.clear
    @State private var cardOverlayOpacity: Double = 0
    @State private var cardStatus = CardStatus.neutral
    @State private var snapPoint: CGFloat = 200
    @State private var isShowingOpenChooser = false
     
    enum CardStatus {
        case disliked
        case liked
        case neutral
    }
     
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    if let imgData = recEntity.musicEntity.imageData, let uiImage = UIImage(data: imgData) {
                        Image(uiImage: uiImage).resizable().scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                    }
                    
                    VStack(alignment: .leading) {
                        Text(recEntity.musicEntity.title)
                            .font(.displayFont(ofSize: 18))
                            .lineLimit(3)
                        Spacer()
                        HStack {
                            if let imgURL = recEntity.artist.artwork?.url(width: 30, height: 30) {
                                Group {
                                    AsyncImage(url: imgURL) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                
                            }
                            Text(recEntity.musicEntity.artistName)
                                .font(.caption)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxHeight: 120)
                
                if let blurb = recEntity.blurb {
                    VStack {
                        Text("\(blurb)")
                            .italic()
                        Link("Apple Music Editorial", destination: URL(string:recEntity.musicEntity.appleMusicURLString)!)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button {
                        isShowingOpenChooser = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("Open...", systemImage: "arrow.up.right.square")
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.secondary)
                    .bold()
                    Button {
                        playInAppleMusicApp()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Play in Apple Music", systemImage: "play")
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .bold()
                }
                .frame(width: 235)
                
                
                Spacer()
                
                HStack {
                    if let imgData = recEntity.recommendationSource.imageData, let uiImage = UIImage(data: imgData) {
                        Image(uiImage: uiImage).resizable().scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                    }
                    
                    Text("Recommended based on \(recEntity.recommendationSource.title) by \(recEntity.recommendationSource.artistName)")
                        .font(.caption)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true))
                        .foregroundStyle(.regularMaterial)
                }
            }
            .padding()
        }
        .frame(height: 540)
        .background {
            if colorScheme == .light {
                ZStack {
                    Color.accentColor
                    Color.white.opacity(0.8)
                }
            } else {
                ZStack {
                    Color.black
                    Color.white.opacity(0.3)
                }
            }
        }
        .overlay {
            ZStack {
                cardOverlayColor
                VStack {
                    if cardStatus == .liked {
                        Image(systemName: "plus.circle")
                            .resizable().scaledToFit()
                            .frame(width: 50)
                        
                        Text("Add to Collection")
                            .bold()
                    } else if cardStatus == .disliked {
                        Group {
                            Image(systemName: "arrowshape.turn.up.left")
                                .resizable().scaledToFit()
                                .frame(width: 50)
                            
                            Text("Skip")
                                .bold()
                        }.foregroundStyle(.white)
                    }
                }
            }
            .opacity(cardOverlayOpacity)
        }
        .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false)))
        .padding()
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    
                    if offset.width > snapPoint - 100 {
                        cardStatus = .liked
                    } else if offset.width < (snapPoint * -1) + 100 {
                        cardStatus = .disliked
                    } else {
                        cardStatus = .neutral
                    }
                }
                .onEnded { _ in
                    // Perform actions based on swipe direction
                    if offset.width > snapPoint {
                        swipeAway(right: true)
                    } else if offset.width < (snapPoint * -1) {
                        swipeAway(right: false)
                    } else {
                        withAnimation {
                            offset = .zero
                            cardStatus = .neutral
                        }
                        
                    }
                }
        )
        .onChange(of: cardStatus) { _, newValue in
            withAnimation {
                switch newValue as CardStatus {
                    case .liked:
                        cardOverlayColor = .accentColor
                        cardOverlayOpacity = 1
                    case .disliked:
                        cardOverlayColor = colorScheme == .light ? .black : .gray
                        cardOverlayOpacity = 1
                    default:
                        cardOverlayColor = .clear
                        cardOverlayOpacity = 0
                }
            }
            
        }
        .confirmationDialog("Open in...", isPresented: $isShowingOpenChooser) {
            Button("Apple Music") {
                Task {
                    do {
                        try await viewModel.amWrangler.openInAppleMusic(recEntity.musicEntity)
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Spotify") {
                Task {
                    do {
                        try await viewModel.spotifyWrangler.openInSpotify(recEntity.musicEntity)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    func swipeAway(right: Bool) {
        print("Swiped \(right ? "right" : "left")")
        withAnimation {
            offset.width = right ? 1000 : -1000
        }
        
        if right {
            print("^^ liked")
        } else {
            print("^^ disliked")
        }
        
        completion(right)
    }
    
    func playInAppleMusicApp() {
        Task {
            do {
                try await viewModel.amWrangler.playInAppleMusicApp(recEntity.musicEntity)
            } catch {
                print("^^ playback error")
            }
        }
    }
}


//#Preview {
//    RecommendationCardView()
//}
