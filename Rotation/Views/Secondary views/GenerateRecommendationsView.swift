//
//  GenerateRecommendationsView.swift
//  Rotation
//
//  Created by Mack Slevin on 7/15/24.
//

import SwiftUI
import SwiftData

struct GenerateRecommendationsView: View {
    @Query var musicEntities: [MusicEntity]
    
    let buttonAction: () -> Void
    var body: some View {
        VStack {
            Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled.fill")
                .resizable().scaledToFit().padding([.horizontal], 60)
                .foregroundStyle(MeshGradient(width: 3, height: 3, points: [
                    .init(0, 0), .init(0.5, 0), .init(1, 0),
                    .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                    .init(0, 1), .init(0.5, 1), .init(1, 1)
                ], colors: [
                    .accent, .accent, .accent,
                    .accent, .secondary, .white,
                    .accent, .accent, .cyan
                ]))
            
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
                    buttonAction()
                }
                .bold()
                .disabled(musicEntities.count < 3)
                .font(Font.displayFont(ofSize: 24))
                
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
    }
}

//#Preview {
//    GenerateRecommendationsView()
//}
