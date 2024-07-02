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
        NavigationStack {
            VStack {
                Spacer()
                
                if viewModel.recommendationsAreLoading {
                    VStack(alignment: .center) {
                        LoadingRecommendationsView(viewModel: viewModel)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                } else if isInitialLoad {
                    HStack {
                        Spacer()
                        Spacer()
                    }
                    VStack {
                        
                        Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled.fill")
                            .resizable().scaledToFit().padding([.horizontal], 60)
                            .foregroundStyle(.quaternary)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("In Rotation can fetch album recommendations based on songs & albums in your collection.")
                            
                            Text("We'll show you some cards with albums on them. Swipe right to save to your collection, swipe left to skip it and move on to the next.")
                        }
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .background {
                            
                            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false))
                                .foregroundStyle(.quaternary)
                                .opacity(0.5)
                        }
                        .padding(.bottom, 40)
                        
                        
                        
                        VStack {
                            Button("Generate Recommendations") {
                                generateRecommendations()
                                isInitialLoad = false
                            }
                            .bold()
                            .disabled(musicEntities.count < 3)
                            
                            if musicEntities.count < 3 {
                                Text("Recommendations work best with more music to go off of. Please add at least three albums to your collection to get started.")
                                    .italic()
                                    .fontWeight(.regular)
                                    .foregroundStyle(.accent)
                                    .padding(.top)
                            }
                        }
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
                    
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
            .background { Utility.customBackground(withColorScheme: colorScheme) }
            .navigationTitle("Explore")
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
                        print("^^ can save? \(canSave)")
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
        .modelContainer(for: MusicEntity.self)
}
