//
//  AddEntityViewModel.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI
import Observation
import MusicKit

@Observable
class AddEntityViewModel {
    var searchText = ""
    var newMusicEntity: MusicEntity?
    var isLoading = false
    var shouldShowError = false
    
    func setMusicEntity<T: MusicItem>(_ musicItem: T) async {
        isLoading = true
        newMusicEntity = await AppleMusicSearchWrangler.shared.makeMusicEntity(from: musicItem)
        await AppleMusicSearchWrangler.shared.reset()
        isLoading = false
    }
}
