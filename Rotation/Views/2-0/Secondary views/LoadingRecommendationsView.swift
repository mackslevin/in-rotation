//
//  LoadingRecommendationsView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/29/24.
//

import SwiftUI

struct LoadingRecommendationsView: View {
    @State var viewModel: ExploreViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "hourglass")
                .resizable().scaledToFit()
                .frame(width: 70)
                .fontWeight(.bold)
            
            VStack(alignment: .center, spacing: -10) {
                Text("Recommendations")
                Text("are loading...")
            }
            .font(.displayFont(ofSize: 32))
            
            ZStack {
                Capsule()
                    .frame(maxHeight: 20)
                    .foregroundStyle(Color.accentColor.gradient)
                ProgressView(value: Double(viewModel.recommendationEntities.count), total: 10)
                    .progressViewStyle(.linear)
                    .tint(.primary)
                    .padding()
            }
            .frame(maxWidth: 400)
            .padding(.bottom, 25)
            .padding(.top, 16)
            
            Text("This will take a moment.")
        }
        .padding()
    }
}

#Preview {
    LoadingRecommendationsView(viewModel: ExploreViewModel())
}
