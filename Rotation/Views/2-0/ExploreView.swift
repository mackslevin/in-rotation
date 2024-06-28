//
//  ExploreView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData
import MusicKit

struct ExploreView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Query var musicEntities: [MusicEntity]
    @State private var viewModel = ExploreViewModel()
    @State private var isInitialLoad = true
    
    @State private var currentCardStatus = CardStatus.neutral
    
    @State private var userHasPremiumAccess = false
    @State private var canSave = true
    
    // These state vars are used to facilitate skipping/saving via the button in this view (as an alternative to simply swiping the card)
    @State private var currentCardID: String? = nil
    @State private var shouldSkipCurrentCard = false
    @State private var shouldSaveCurrentCard = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Explore")
                    .listRowBackground(Color.clear)
                    .font(Font.displayFont(ofSize: 32))
                    .bold()
                    .foregroundStyle(.tint)
                
                Spacer()
            }
            
            Spacer()
            
            if viewModel.recommendationsAreLoading {
                VStack(alignment: .center, spacing: 40) {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("Loading your recommendations.")
                        Text("This will take a moment.")
                    }
                    .font(.displayFont(ofSize: 20))
                    .foregroundStyle(.tint)
                    ProgressView(value: Double(viewModel.recommendationEntities.count), total: 10)
                        .progressViewStyle(.linear)
                        .tint(.accentColor)
                    Spacer()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
            } else if isInitialLoad {
                HStack {
                    Spacer()
                    Spacer()
                }
                VStack(spacing: 40) {
                    Image(systemName: "rectangle.on.rectangle.angled")
                        .resizable().scaledToFit().padding([.horizontal], 50)
                        .foregroundColor(.accentColor)
                    
                    Text("In Rotation can fetch album recommendations based on songs & albums in your collection.")
                    
                    Text("Swipe right to add an album to your library. Swipe left to skip.")
                    
                    VStack {
                        Button("Generate Recommendations") {
                            generateRecommendations()
                            isInitialLoad = false
                        }
                        .bold().buttonStyle(.borderedProminent)
                        .disabled(musicEntities.count < 3)
                        
                        if musicEntities.count < 3 {
                            Text("Recommendations work best with more music to go off of. Please add at least three albums to your collection to get started.")
                                .italic()
                                .fontWeight(.regular)
                                .foregroundStyle(.accent)
                        }
                    }
                }
                .multilineTextAlignment(.center)
                
            } else if viewModel.recommendationEntities.isEmpty {
                Button {
                    generateRecommendations()
                } label: {
                    Label("Load More Recommendations", systemImage: "arrow.circlepath")
                }
                .bold()
            } else {
                ZStack {
                    ForEach(viewModel.recommendationEntities) { rec in
                        RecommendationCardView(
                            recEntity: rec,
                            viewModel: viewModel,
                            hostingViewCardStatus: $currentCardStatus, 
                            userCanSaveToCollection: $canSave,
                            currentCardID: $currentCardID,
                            shouldSkipCurrentCard:$shouldSkipCurrentCard,
                            shouldSaveCurrentCard: $shouldSaveCurrentCard
                            ) { liked in
                                handleRecommendation(rec, liked: liked)
                                currentCardStatus = .neutral
                                shouldSaveCurrentCard = false
                                shouldSkipCurrentCard = false
                        }
                    }
                }
                .zIndex(100)
                
                HStack(spacing: 50) {
                    HStack {
                        Image(systemName: currentCardStatus == .disliked ? "arrowshape.turn.up.left.fill" : "arrowshape.turn.up.left")
                        Text("Skip")
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(currentCardStatus == .disliked ? Color.primary : Color.gray)
                    .onTapGesture {
                        shouldSkipCurrentCard = true
                        shouldSaveCurrentCard = false
                    }
                    
                    HStack {
                        Text("Save")
                        Image(systemName: currentCardStatus == .liked ? "arrowshape.turn.up.right.fill" : "arrowshape.turn.up.right")
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(currentCardStatus == .liked ? Color.accentColor : Color.gray)
                    .onTapGesture {
                        shouldSaveCurrentCard = true
                        shouldSkipCurrentCard = false
                    }
                        
                }
                .bold()
            }
            
            Spacer()
        }
        .padding()
        .background { Utility.customBackground(withColorScheme: colorScheme) }
        .currentEntitlementTask(for: Utility.premiumUnlockProductID) { state in
            switch state {
                case .loading:
                    print("^^ state is loading")
                case .failure(let error):
                    print("^^ state failed, error is \(error)")
                case .success(let transaction):
                    print("^^ state is success")
                    userHasPremiumAccess = transaction != nil
                    canSave = userHasPremiumAccess || musicEntities.count < Utility.maximumFreeEntities
                @unknown default:
                    fatalError()
            }
        }
        .onChange(of: canSave) { oldValue, newValue in
            print("can save? \(newValue)")
        }
        .onChange(of: viewModel.recommendationEntities) { oldValue, newValue in
            currentCardID = getCurrentCardID()
        }
    }
    
    func handleRecommendation(_ rec: RecommendationEntity, liked: Bool) {
        viewModel.recommendationEntities.removeAll(where: {$0.id == rec.id})
        if liked {
            modelContext.insert(rec.musicEntity)
        }
        
    }
    
    func generateRecommendations() {
        Task {
            do {
                try await viewModel.fillRecommendations(withSources: musicEntities)
            } catch {
                print(error)
            }
        }
    }
    
    func getCurrentCardID() -> String? {
        if let recEnt = viewModel.recommendationEntities.last {
            return recEnt.id.uuidString
        }
        
        return nil
    }
}

#Preview {
    ExploreView()
}
