//
//  RecommendationEntity.swift
//  Rotation
//
//  Created by Mack Slevin on 12/6/23.
//

import Foundation
import Observation
import MusicKit

@Observable
class RecommendationEntity: Identifiable, Equatable {
    let id = UUID()
    let musicEntity: MusicEntity
    let recommendationSource: MusicEntity
    let blurb: String? // Apple Music's short description, if available.
    let artist: Artist
    
    init(musicEntity: MusicEntity, recommendationSource: MusicEntity, blurb: String? = nil, artist: Artist) {
        self.musicEntity = musicEntity
        self.recommendationSource = recommendationSource
        self.blurb = blurb
        self.artist = artist
    }
    
    static func == (lhs: RecommendationEntity, rhs: RecommendationEntity) -> Bool {
        lhs.id == rhs.id
    }
    
    
}
