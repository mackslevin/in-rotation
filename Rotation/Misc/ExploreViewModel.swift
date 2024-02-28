//
//  ExploreViewModel.swift
//  Rotation
//
//  Created by Mack Slevin on 12/7/23.
//

import Foundation
import Observation
import MusicKit

enum ExploreError: String, Error {
    case unableToFillRecommendations = "Unable to generate recommendations. Please try again."
}


@Observable
class ExploreViewModel {
    var recommendationEntities: [RecommendationEntity] = []
    
    let amWrangler = AppleMusicWrangler()
    let amSearchWrangler = AppleMusicSearchWrangler()
    var recommendationsAreLoading = false
    
    func fillRecommendations(withSources sources: [MusicEntity]) async throws {
        // TODO: Throw less often so that this isn't adandoned because of, like, an error getting image data
        
        guard !sources.isEmpty else { throw ExploreError.unableToFillRecommendations }
        
        recommendationsAreLoading = true
        recommendationEntities = []
        var attempts = 0
        
        while recommendationEntities.count < 10 && attempts <= 200 {
            attempts += 1
            
            // Grab random source MusicEntity
            guard let sourceMusicEntity = sources.randomElement() else { try abortRecommendationGeneration(); return }
            
            // If this source is an album
            if sourceMusicEntity.type == .album {
                guard !sourceMusicEntity.appleMusicID.isEmpty else { print("^^ No AM ID"); continue }
                
                // Convert to MusicItem populated with related albums and with artists
                var sourceMusicItemRequest = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: MusicItemID(sourceMusicEntity.appleMusicID))
                sourceMusicItemRequest.properties = [.relatedAlbums, .artists]
                let result = try await sourceMusicItemRequest.response()
                guard let sourceMusicItem = result.items.first else { print("^^ no resource req result"); continue }
                
                // Create variable to store the ID of the album we'll be recommending
                var recommendedAlbumID = ""
                
                // Find an album either from the related albums or from a related artist's albums
                if let relatedAlbums = sourceMusicItem.relatedAlbums, relatedAlbums.count > 0, let randomRelatedAlbum = relatedAlbums.randomElement() {
                    
                    guard !matchExists(forAlbum: randomRelatedAlbum, inCollection: sources), !alreadyExistsInRecommendations(randomRelatedAlbum) else { print("^^ Skipping duplicate"); continue }
                    
                    print("^^ Found a related album")
                    recommendedAlbumID = randomRelatedAlbum.id.rawValue
                    
                } else {
                    print("^^ Gonna try to find a similar artist album...")
                    guard let artist = sourceMusicItem.artists?.first else { print("^^ No source artist"); continue }
                    guard let relatedArtist = artist.similarArtists?.randomElement() else { print("^^ No related artists"); continue }
                    let populatedRelated = try await relatedArtist.with([.albums])
                    guard let randomRelatedArtistAlbum = populatedRelated.albums?.randomElement() else { print("^^ No related artist albums"); continue }
                    recommendedAlbumID = randomRelatedArtistAlbum.id.rawValue
                }
                
                guard !recommendedAlbumID.isEmpty else { print("^^ rec album id is empty"); continue }
                
                // Use ID for catalog resource request for MusicItem populated with artists and editorial
                var recommendedMusicItemRequest = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: MusicItemID(recommendedAlbumID))
                recommendedMusicItemRequest.properties = [.artists]
                let recReqResult = try await recommendedMusicItemRequest.response()
                guard let recMusicItem = recReqResult.items.first else { print("^^ no results for recommended album music item request"); continue }
                
                
                // Get artist
                guard let recAlbumArtist = recMusicItem.artists?.first else { print("^^ No artist for recommended album"); continue}
                
                // Get image data
                var imgData: Data? = nil
                if let artURL = recMusicItem.artwork?.url(width: 1000, height: 1000) {
                    imgData = try Data(contentsOf: artURL)
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
                print("^^ Starting with a song")
                // Get source Artist MusicItem
                guard !sourceMusicEntity.appleMusicID.isEmpty else { print("^^ No AM ID"); continue }
                var sourceRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(sourceMusicEntity.appleMusicID))
                sourceRequest.properties = [.artists]
                let result = try await sourceRequest.response()
                guard let sourceMusicItem = result.items.first else { continue }
                
                // Get related artist
                guard let sourceArtist = sourceMusicItem.artists?.randomElement() else { print("^^ Song - no source artist"); continue }
                guard let populatedSourceArtist = try? await sourceArtist.with([.similarArtists]) else { continue }
                guard let relatedArtist = populatedSourceArtist.similarArtists?.randomElement() else { print("^^ Song - No related artists"); continue }
                guard let populatedRelatedArtist = try? await relatedArtist.with([.albums]) else { continue }
                
                // Get related artist album
                guard let relatedArtistAlbum = populatedRelatedArtist.albums?.randomElement() else { print("^^ Song - No related artist albums"); continue }
                
                // Get album art Data
                var imgData: Data? = nil
                if let artURL = relatedArtistAlbum.artwork?.url(width: 1000, height: 1000) {
                    imgData = try Data(contentsOf: artURL)
                    print("^^ Song - Got image data")
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
                
                print("^^ Added from a song source")
            }
        } // END WHILE LOOP
        
        print("^^ total attempts: \(attempts)")
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
}

