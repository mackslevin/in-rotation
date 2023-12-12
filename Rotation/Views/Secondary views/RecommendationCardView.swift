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
    
    // Image intermediaries given values on appear. For performance.
    @State private var coverThumbnail: Image? = nil
    @State private var sourceThumbnail: Image? = nil
    
    @State private var isShowingSpotifyOpenError = false
    @State private var isShowingAppleMusicOpenError = false
     
    enum CardStatus {
        case disliked
        case liked
        case neutral
    }
     
    var body: some View {
        VStack {
            HStack {
                if let imgURL = recEntity.artist.artwork?.url(width: 60, height: 60) {
                    AsyncImage(url: imgURL) { artistImage in
                        ZStack {
                            Circle().foregroundStyle(.thickMaterial)
                            artistImage.resizable().scaledToFill()
                                .clipShape(Circle())
                                .padding(2)
                        }
                        .frame(width: 44, height: 44)
//                        .shadow(radius: 8)
                        
                    } placeholder: {
                        ProgressView()
                            .frame(width: 44, height: 44)
                    }
                }
                
                Text("\(recEntity.musicEntity.title) by \(recEntity.musicEntity.artistName)")
                    .font(.displayFont(ofSize: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                Spacer()
            }
            
            
            if let coverThumbnail {
                coverThumbnail.resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
//                    .overlay {
//                        VStack {
//                            HStack {
//                                Spacer()
//                                
//                                // image
//                                if let imgURL = recEntity.artist.artwork?.url(width: 60, height: 60) {
//                                    AsyncImage(url: imgURL) { artistImage in
//                                        ZStack {
//                                            Circle().foregroundStyle(.thickMaterial)
//                                            artistImage.resizable().scaledToFill()
//                                                .clipShape(Circle())
//                                                .padding(4)
//                                        }
//                                        .frame(width: 44, height: 44)
//                                        .shadow(radius: 8)
//                                        
//                                    } placeholder: {
//                                        ProgressView()
//                                            .frame(width: 44, height: 44)
//                                    }
//                                }
//                            }
//                            Spacer()
//                        }
//                        .padding()
//                    }
            }
            
            Spacer()
            CardActionBlock(recEntity: recEntity, isShowingOpenChooser: $isShowingOpenChooser, viewModel: viewModel)
            Spacer()
            
            HStack {
                if let sourceThumbnail {
                    sourceThumbnail.resizable().scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                }
                
                Text("Recommended based on \(recEntity.recommendationSource.title) by \(recEntity.recommendationSource.artistName)")
                    .font(.caption)
                
                Spacer()
            }
            .padding()
            .background { RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)).foregroundStyle(.regularMaterial) }
        }
        .padding()
        .frame(height: 560)
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
        .onAppear {
            if let coverData = recEntity.musicEntity.imageData, let coverUIImage = UIImage(data: coverData) {
                coverThumbnail = Image(uiImage: coverUIImage)
            }
            
            if let sourceImageData = recEntity.recommendationSource.imageData, let sourceUIImage = UIImage(data: sourceImageData) {
                sourceThumbnail = Image(uiImage: sourceUIImage)
            }
        }
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
                        isShowingSpotifyOpenError = true
                    }
                }
            }
        }
        .alert("Unable to find matching album on Spotify", isPresented: $isShowingSpotifyOpenError) {
            Button("OK"){}
        }
        .alert("Unable to open album in Apple Music", isPresented: $isShowingAppleMusicOpenError) {
            Button("OK"){}
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
