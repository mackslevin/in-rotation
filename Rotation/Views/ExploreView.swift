//
//  ExploreView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData

struct ExploreView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Query var musicEntities: [MusicEntity]
    @State private var viewModel = ExploreViewModel()
    @State private var isInitialLoad = true
    
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
                VStack(alignment: .leading, spacing: 40) {
                    Spacer()
                    ProgressView(value: Double(viewModel.recommendationEntities.count), total: 10)
                        .progressViewStyle(.linear)
                        .tint(.accentColor)
                    Text("Loading your recommendations. This will take a moment.")
                        .font(.displayFont(ofSize: 20))
                        .foregroundStyle(.tint)
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
                    
                    Text("In Rotation can collect album recommendations based on songs & albums in your Library.")
                    
                    Text("Swipe right to add an album to your library. Swipe left to skip.")
                    
                    Button("Generate Recommendations") {
                        generateRecommendations()
                        isInitialLoad = false
                    }
                    .bold().buttonStyle(.borderedProminent)
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
                        RecommendationCardView(recEntity: rec, viewModel: viewModel) { liked in
                            handleRecommendation(rec, liked: liked)
                        }
                    }
                }
                
            }
            
            Spacer()
        }
        .padding()
        .background { Utility.customBackground(withColorScheme: colorScheme) }
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
}

#Preview {
    ExploreView()
}
