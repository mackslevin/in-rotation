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
    @Binding var hostingViewCardStatus: CardStatus
    @Binding var userCanSaveToCollection: Bool
    @Binding var currentCardID: String?
    @Binding var shouldSkipCurrentCard: Bool
    @Binding var shouldSaveCurrentCard: Bool
    let completion: (Bool) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var offset: CGSize = .zero
    @State private var cardOverlayColor = Color.clear
    @State private var cardOverlayOpacity: Double = 0
    @State private var cardStatus = CardStatus.neutral
    @State private var snapPoint: CGFloat = 200
    @State private var rotation: Double = 0.0
    
    
    // Image intermediaries given values on appear. For performance.
    @State private var coverThumbnail: Image? = nil
    @State private var sourceThumbnail: Image? = nil
    
    @State private var isShowingSpotifyOpenError = false
    @State private var isShowingAppleMusicOpenError = false
    @State private var isShowingOpenChooser = false
    @State private var isShowingIAPPaywall = false
    
    let rightSwipeLimitWhenWeCantSave: CGFloat = 150
     
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
                
                VStack {
                    Text("Recommended based on \(recEntity.recommendationSource.title) by \(recEntity.recommendationSource.artistName)")
                }
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
                    Rectangle().foregroundStyle(Color.accentColor.gradient)
                    Color.white.opacity(0.7)
                }
            } else {
                ZStack {
                    Rectangle().foregroundStyle(Color.black.gradient)
                    Color.white.opacity(0.3)
                }
            }
        }
        .overlay {
            ZStack {
                cardOverlayColor
                VStack {
                    if cardStatus == .liked {
                        HStack {
                            Image(systemName: "plus.circle")
                                .resizable().scaledToFit()
                                .frame(width: 50)
                            Spacer()
                        }.padding()
                        
                    } else if cardStatus == .disliked {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "xmark.circle")
                                .resizable().scaledToFit()
                                .frame(width: 50)
                                .foregroundStyle(.white)
                            
                        }.padding()
                        
                    }
                    
                    Spacer()
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
            
            if recEntity.musicEntity.serviceLinks.isEmpty, !recEntity.musicEntity.appleMusicURLString.isEmpty {
                print("^^ gonna grab links")
                
                Task {
                    if let linkCollection = try await ServiceLinksCollection.linkCollection(fromServiceURL: recEntity.musicEntity.appleMusicURLString) {
                        print("^^ got a collection \(linkCollection)")
                        
                        recEntity.musicEntity.serviceLinks = linkCollection.simpleLinks
                    }
                }
            }
        }
        .rotationEffect(Angle(degrees: rotation))
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    
                    if userCanSaveToCollection || gesture.translation.width <= rightSwipeLimitWhenWeCantSave {
                        offset = gesture.translation
                    }
                    
                    // If the user can't save (i.e. their collection is at the limit and they haven't made the IAP) and they're in the general range of non-saveable right swipe limit, show the IAP paywall/offer view
                    if !userCanSaveToCollection && gesture.translation.width > (rightSwipeLimitWhenWeCantSave - 20) {
                        isShowingIAPPaywall = true
                        withAnimation {
                            offset = .zero
                            rotation = 0
                            cardStatus = .neutral
                        }
                        return
                    }
                    
                    // Calculate rotation amount
                    let sampledOffset = offset.width / 15
                    let rotationLimit: Double = 15
                    withAnimation {
                        rotation = sampledOffset > rotationLimit ? rotationLimit : sampledOffset < (rotationLimit * -1) ? (rotationLimit * -1) : sampledOffset
                    }
                    
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
                    
                    if offset.width == 0 {
                        withAnimation(.bouncy) {
                            rotation = 0
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
                
                if hostingViewCardStatus != newValue {
                    hostingViewCardStatus = newValue
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
            
            if let urlStr = recEntity.musicEntity.serviceLinks["spotify"], let url = URL(string: urlStr) {
                Button("Spotify") {
                    UIApplication.shared.open(url)
                }
            }
        }
        .alert("Unable to find matching album on Spotify", isPresented: $isShowingSpotifyOpenError) {
            Button("OK"){}
        }
        .alert("Unable to open album in Apple Music", isPresented: $isShowingAppleMusicOpenError) {
            Button("OK"){}
        }
        .sheet(isPresented: $isShowingIAPPaywall) {
            IAPPaywallView()
                .onDisappear {
                    shouldSaveCurrentCard = false
                }
        }
        .onChange(of: shouldSkipCurrentCard) { _, newValue in
            if newValue, let currentCardID, currentCardID == recEntity.id.uuidString {
                handleSavingByButton()
            }
        }
        .onChange(of: shouldSaveCurrentCard) { _, newValue in
            if newValue, let currentCardID, currentCardID == recEntity.id.uuidString {
                handleSavingByButton()
            }
        }
    }
    
    func swipeAway(right: Bool) {
        withAnimation {
            offset.width = right ? 1000 : -1000
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
    
    func handleSavingByButton() {
        if shouldSaveCurrentCard && !userCanSaveToCollection {
            isShowingIAPPaywall = true
        } else {
            withAnimation(.easeIn(duration: 0.7)) {
                cardStatus = shouldSaveCurrentCard ? .liked : .disliked
            }
            
            withAnimation(.easeIn(duration: 1.7)) {
                offset.width = shouldSaveCurrentCard ? 1000 : -1000
                rotation = shouldSaveCurrentCard ? 25 : -25
            } completion: {
                completion(shouldSaveCurrentCard)
            }
        }
    }
}


//#Preview {
//    RecommendationCardView()
//}
