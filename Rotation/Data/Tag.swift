//
//  Tag.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import Foundation
import SwiftData

@Model
class Tag {
    let id = UUID()
    let title: String = ""
    let symbolName: String = "tag.fill"
    
    @Relationship(inverse: \MusicEntity.tags) var musicEntities: [MusicEntity]?
    
    init(title: String, symbolName: String = "tag.fill", musicEntities: [MusicEntity]? = []) {
        self.title = title
        self.symbolName = symbolName
        self.musicEntities = musicEntities
    }
}
