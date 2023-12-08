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
                VStack(spacing: 40) {
                    Spacer()
                    ProgressView()
//                        .tint(.accentColor)
                        .progressViewStyle(.linear)
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
            } else if viewModel.recommendationEntities.count >= 10 {
                VStack {
                    ForEach(viewModel.recommendationEntities) { rec in
                        VStack(alignment: .leading) {
                            Text(rec.musicEntity.title)
                            Text(rec.musicEntity.artistName)
                                .bold()
                            Text("Recommended based on \(rec.recommendationSource.title)")
                                .font(.caption)
                        }
                        
                    }
                }
                
            }
            
            Spacer()
        }
        .padding()
        .background { Utility.customBackground(withColorScheme: colorScheme) }
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
