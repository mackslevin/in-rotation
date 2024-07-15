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
                    
                } else if viewModel.isInitialLoad {
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
                                viewModel.generateRecommendations(fromMusicEntities: musicEntities)
                                viewModel.isInitialLoad = false
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
                        viewModel.generateRecommendations(fromMusicEntities: musicEntities)
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
                                hostingViewCardStatus: $viewModel.currentCardStatus,
                                userCanSaveToCollection: $viewModel.canSave,
                                currentCardID: $viewModel.currentCardID,
                                shouldSkipCurrentCard:$viewModel.shouldSkipCurrentCard,
                                shouldSaveCurrentCard: $viewModel.shouldSaveCurrentCard
                                ) { liked in
                                    viewModel.handleRecommendation(rec, liked: liked, modelContext: modelContext)
                                    viewModel.currentCardStatus = .neutral
                                    viewModel.shouldSaveCurrentCard = false
                                    viewModel.shouldSkipCurrentCard = false
                            }
                        }
                    }
                    .zIndex(100)
                    
                    HStack(spacing: 50) {
                        HStack {
                            Image(systemName: viewModel.currentCardStatus == .disliked ? "arrowshape.turn.up.left.fill" : "arrowshape.turn.up.left")
                            Text("Skip")
                        }
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.currentCardStatus == .disliked ? Color.primary : Color.gray)
                        .onTapGesture {
                            viewModel.shouldSkipCurrentCard = true
                            viewModel.shouldSaveCurrentCard = false
                        }
                        
                        HStack {
                            Text("Save")
                            Image(systemName: viewModel.currentCardStatus == .liked ? "arrowshape.turn.up.right.fill" : "arrowshape.turn.up.right")
                        }
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.currentCardStatus == .liked ? Color.accentColor : Color.gray)
                        .onTapGesture {
                            viewModel.shouldSaveCurrentCard = true
                            viewModel.shouldSkipCurrentCard = false
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
                        viewModel.userHasPremiumAccess = transaction != nil
                        viewModel.canSave = viewModel.userHasPremiumAccess || musicEntities.count < Utility.maximumFreeEntities
                        print("^^ can save? \(viewModel.canSave)")
                    @unknown default:
                        fatalError()
                }
            }
            .onChange(of: viewModel.canSave) { oldValue, newValue in
                print("can save? \(newValue)")
            }
            .onChange(of: viewModel.recommendationEntities) { oldValue, newValue in
                viewModel.currentCardID = viewModel.getCurrentCardID()
            }
        }
        
    }
    
    
}

#Preview {
    ExploreView()
        .modelContainer(for: MusicEntity.self)
}
