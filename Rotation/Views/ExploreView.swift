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
                    GenerateRecommendationsView {
                        viewModel.generateRecommendations(fromMusicEntities: musicEntities)
                        viewModel.isInitialLoad = false
                    }
                } else if viewModel.recommendationEntities.isEmpty {
                    Button {
                        viewModel.generateRecommendations(fromMusicEntities: musicEntities)
                    } label: {
                        Label("Load More Recommendations", systemImage: "arrow.circlepath")
                    }
                    .bold()
                    .buttonStyle(.bordered)
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
                    .zIndex(1000)
                    
                    RecommendationSaveSkipView(viewModel: viewModel)
                        .padding(.bottom, 20)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
            .background { Utility.customBackground(withColorScheme: colorScheme) }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
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
