//
//  ExploreViewModel.swift
//  Rotation
//
//  Created by Mack Slevin on 12/7/23.
//

import Foundation
import MusicKit
import SwiftData

enum ExploreError: String, Error {
    case unableToFillRecommendations = "Unable to generate recommendations. Please try again."
}

@Observable
class ExploreViewModel {
    var recommendationEntities: [RecommendationEntity] = []
    
    let amWrangler = AppleMusicWrangler()
    let amSearchWrangler = AppleMusicSearchWrangler()
    
    var recommendationsAreLoading = false
    var isInitialLoad = true
    var currentCardStatus = CardStatus.neutral
    var userHasPremiumAccess = false
    var canSave = true
    var currentCardID: String? = nil
    
    // These state vars are used to facilitate skipping/saving via the button in the view (as an alternative to simply swiping the card)
    var shouldSkipCurrentCard = false
    var shouldSaveCurrentCard = false
    
    func fillRecommendations(withSources sources: [MusicEntity]) async throws {
        guard !sources.isEmpty else {
            throw ExploreError.unableToFillRecommendations
        }
        
        recommendationsAreLoading = true
        recommendationEntities = []
        var attempts = 0
        
        while recommendationEntities.count < 10 && attempts <= 200 {
            // Grab random source MusicEntity
            guard let sourceMusicEntity = sources.randomElement() else {
                try abortRecommendationGeneration()
                return
            }
            
            // If this source is an album
            if sourceMusicEntity.type == .album {
                guard !sourceMusicEntity.appleMusicID.isEmpty else {
                    continue
                }
                
                // Convert to MusicItem populated with related albums and with artists
                var sourceMusicItemRequest = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: MusicItemID(sourceMusicEntity.appleMusicID))
                sourceMusicItemRequest.properties = [.relatedAlbums, .artists]
                let result = try? await sourceMusicItemRequest.response()
                guard let sourceMusicItem = result?.items.first else {
                    continue
                }
                
                // Create variable to store the ID of the album we'll be recommending
                var recommendedAlbumID = ""
                
                // Find an album either from the related albums or from a related artist's albums
                if let relatedAlbums = sourceMusicItem.relatedAlbums, relatedAlbums.count > 0, let randomRelatedAlbum = relatedAlbums.randomElement() {
                    
                    guard !matchExists(forAlbum: randomRelatedAlbum, inCollection: sources), !alreadyExistsInRecommendations(randomRelatedAlbum) else {
                        continue
                    }
                    
                    recommendedAlbumID = randomRelatedAlbum.id.rawValue
                } else {
                    guard let artist = sourceMusicItem.artists?.first else { continue }
                    
                    // Populate with similar artists
                    let popArtist = try? await artist.with([.similarArtists])
                    
                    guard let relatedArtist = popArtist?.similarArtists?.randomElement() else { continue }
                    
                    let populatedRelated = try? await relatedArtist.with([.albums])
                    guard let randomRelatedArtistAlbum = populatedRelated?.albums?.randomElement() else { continue }
                    
                    recommendedAlbumID = randomRelatedArtistAlbum.id.rawValue
                }
                
                guard !recommendedAlbumID.isEmpty else { continue }
                
                // Use ID for catalog resource request for MusicItem populated with artists and editorial
                var recommendedMusicItemRequest = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: MusicItemID(recommendedAlbumID))
                recommendedMusicItemRequest.properties = [.artists]
                let recReqResult = try? await recommendedMusicItemRequest.response()
                guard let recMusicItem = recReqResult?.items.first else { continue }
                
                // Get artist
                guard let recAlbumArtist = recMusicItem.artists?.first else { continue}
                
                // Get image data
                var imgData: Data? = nil
                if let artURL = recMusicItem.artwork?.url(width: 1000, height: 1000) {
                    imgData = try? Data(contentsOf: artURL)
                }
                
                // Convert recommended album to MusicEntity
                let recMusicEntity = MusicEntity(
                    title: recMusicItem.title,
                    artistName: recMusicItem.artistName,
                    releaseDate: recMusicItem.releaseDate ?? .distantFuture,
                    numberOfTracks: recMusicItem.trackCount,
                    songTitles: recMusicItem.tracks?.map({$0.title}) ?? [],
                    duration: recMusicItem.tracks?.map({$0.duration ?? .zero}).reduce(0.0, { partialResult, timeInt in
                        partialResult + timeInt
                    }) ?? .zero,
                    imageData: imgData,
                    played: false,
                    type: .album,
                    recordLabel: recMusicItem.recordLabelName ?? "",
                    isrc: "",
                    upc: recMusicItem.upc ?? "",
                    appleMusicURLString: recMusicItem.url?.absoluteString ?? "",
                    appleMusicID: recMusicItem.id.rawValue,
                    serviceLinks: [:],
                    tags: [],
                    notes: ""
                )
                
                recommendationEntities.append(
                    RecommendationEntity(musicEntity: recMusicEntity, recommendationSource: sourceMusicEntity, blurb: recMusicItem.editorialNotes?.short ?? "", artist: recAlbumArtist)
                )
                
            } else if sourceMusicEntity.type == .song {
                // Get source Artist MusicItem
                guard !sourceMusicEntity.appleMusicID.isEmpty else { continue }
                var sourceRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(sourceMusicEntity.appleMusicID))
                sourceRequest.properties = [.artists]
                let result = try? await sourceRequest.response()
                guard let sourceMusicItem = result?.items.first else { continue }
                
                // Get related artist
                guard let sourceArtist = sourceMusicItem.artists?.randomElement() else { continue }
                guard let populatedSourceArtist = try? await sourceArtist.with([.similarArtists]) else { continue }
                guard let relatedArtist = populatedSourceArtist.similarArtists?.randomElement() else { continue }
                guard let populatedRelatedArtist = try? await relatedArtist.with([.albums]) else { continue }
                
                // Get related artist album
                guard let relatedArtistAlbum = populatedRelatedArtist.albums?.randomElement() else { continue }
                
                // Get album art Data
                var imgData: Data? = nil
                if let artURL = relatedArtistAlbum.artwork?.url(width: 1000, height: 1000) {
                    imgData = try? Data(contentsOf: artURL)
                }
                
                // Convert to MusicEntity
                let recMusicEntity = MusicEntity(
                    title: relatedArtistAlbum.title,
                    artistName: relatedArtistAlbum.artistName,
                    releaseDate: relatedArtistAlbum.releaseDate ?? .distantFuture,
                    numberOfTracks: relatedArtistAlbum.trackCount,
                    songTitles: relatedArtistAlbum.tracks?.map({$0.title}) ?? [],
                    duration: relatedArtistAlbum.tracks?.map({$0.duration ?? .zero}).reduce(0.0, { partialResult, timeInt in
                        partialResult + timeInt
                    }) ?? .zero,
                    imageData: imgData,
                    played: false,
                    type: .album,
                    recordLabel: relatedArtistAlbum.recordLabelName ?? "",
                    isrc: "",
                    upc: relatedArtistAlbum.upc ?? "",
                    appleMusicURLString: relatedArtistAlbum.url?.absoluteString ?? "",
                    appleMusicID: relatedArtistAlbum.id.rawValue,
                    serviceLinks: [:],
                    tags: [],
                    notes: ""
                )
                
                // Add recommendation
                recommendationEntities.append(
                    RecommendationEntity(musicEntity: recMusicEntity, recommendationSource: sourceMusicEntity, blurb: relatedArtistAlbum.editorialNotes?.short ?? "", artist: relatedArtist)
                )
            }
            
            attempts += 1
        } // END WHILE LOOP
        
        recommendationsAreLoading = false
    }
    
    func abortRecommendationGeneration() throws {
        recommendationEntities = []
        recommendationsAreLoading = false
        throw ExploreError.unableToFillRecommendations
    }
    
    func matchExists(forAlbum album: Album, inCollection collection: [MusicEntity]) -> Bool {
        for musicEntity in collection {
            if musicEntity.title == album.title && musicEntity.artistName == album.artistName {
                return true
            }
        }
        
        return false
    }
    
    func alreadyExistsInRecommendations(_ musicItem: MusicItem) -> Bool {
        for rec in recommendationEntities {
            if rec.musicEntity.appleMusicID == musicItem.id.rawValue {
                return true
            }
        }
        
        return false
    }
    
    func handleRecommendation(_ rec: RecommendationEntity, liked: Bool, modelContext: ModelContext) {
        recommendationEntities.removeAll(where: {$0.id == rec.id})
        if liked {
            modelContext.insert(rec.musicEntity)
        }
    }
    
    func generateRecommendations(fromMusicEntities musicEntities: [MusicEntity]) {
        Task {
            do {
                try await fillRecommendations(withSources: musicEntities)
            } catch {
                print(error)
            }
        }
    }
    
    func getCurrentCardID() -> String? {
        if let recEnt = recommendationEntities.last {
            return recEnt.id.uuidString
        }
        
        return nil
    }
}

