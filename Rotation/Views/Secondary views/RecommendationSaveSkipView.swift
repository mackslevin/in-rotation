//
//  RecommendationSaveSkipView.swift
//  Rotation
//
//  Created by Mack Slevin on 7/15/24.
//

import SwiftUI

struct RecommendationSaveSkipView: View {
    @Bindable var viewModel: ExploreViewModel
    
    var body: some View {
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
}

//#Preview {
//    RecommendationSaveSkipView()
//}
