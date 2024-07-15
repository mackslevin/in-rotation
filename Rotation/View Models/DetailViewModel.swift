//
//  DetailViewModel.swift
//  Rotation
//
//  Created by Mack Slevin on 6/20/24.
//

import SwiftUI
import Observation
import MediaPlayer
import MusicKit

@Observable
class DetailViewModel {
    var isSavedToUserLibrary: Bool? = false
    var musicLibraryAuthStatus: MPMediaLibraryAuthorizationStatus? = nil
    var isShowingAddSuccess = false
    
    var error: (any Error)? = nil
    
    func setUp(_ musicEntity: MusicEntity) async throws {
        await setUpAuth()
        self.isSavedToUserLibrary = try await existsInUserLibrary(musicEntity)
    }
    
    @MainActor
    func addToUserLibrary(_ musicEntity: MusicEntity, appleMusicWrangler: AppleMusicWrangler) async {
        do {
            if let addableMusicItem = try await appleMusicWrangler.appleMusicItemFromMusicEntity(musicEntity) as? MusicLibraryAddable {
                try await MusicLibrary.shared.add(addableMusicItem)
                self.isSavedToUserLibrary = try await existsInUserLibrary(musicEntity)
                if self.isSavedToUserLibrary == true {
                    isShowingAddSuccess = true
                }
            } else {
                self.error = DetailViewError.unableToAddToLibrary
            }
        } catch {
            self.error = error
            return
        }
    }
    
    @MainActor
    private func setUpAuth() async {
        self.musicLibraryAuthStatus = await MPMediaLibrary.requestAuthorization()
    }
    
    @MainActor
    private func existsInUserLibrary(_ musicEntity: MusicEntity) async throws -> Bool {
        
        
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            throw DetailViewError.mediaLibraryNotAuthorized
        }
        
        var query: MPMediaQuery? = nil
        switch musicEntity.type {
            case .song:
                query = MPMediaQuery.songs()
            case .album:
                query = MPMediaQuery.albums()
            case .playlist:
                return false
        }
        guard let query else { return false }
        
        query.addFilterPredicate(MPMediaPropertyPredicate(value: musicEntity.artistName, forProperty: MPMediaItemPropertyArtist))
        query.addFilterPredicate(MPMediaPropertyPredicate(value: musicEntity.title, forProperty: musicEntity.type == .album ? MPMediaItemPropertyAlbumTitle : MPMediaItemPropertyTitle))
        
        if let items = query.items, items.count > 0 {
            return true
        }
        
        return false
        
        
        
        
    }
}

enum DetailViewError: Error, LocalizedError {
    case mediaLibraryNotAuthorized
    case unableToAddToLibrary
    case functionalityUnavailableOnMac
    
    var errorDescription: String? {
        switch self {
            case .mediaLibraryNotAuthorized:
                return NSLocalizedString("Unable to access the music library due to lack of authorization", comment: "")
            case .unableToAddToLibrary:
                return NSLocalizedString("Unable to add the item to the musc library at this time", comment: "")
            case .functionalityUnavailableOnMac:
                return NSLocalizedString("Cannot perform this action on macOS", comment: "")
        }
    }
}
