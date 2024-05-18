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
        
        guard !sources.isEmpty else {
            print("^^ Sources empty")
            throw ExploreError.unableToFillRecommendations
        }
        
        recommendationsAreLoading = true
        recommendationEntities = []
        var attempts = 0
        
        while recommendationEntities.count < 10 && attempts <= 200 {
            // Grab random source MusicEntity
            guard let sourceMusicEntity = sources.randomElement() else {
                print("^^ Aborting")
                try abortRecommendationGeneration()
                return
            }
            
            // If this source is an album
            if sourceMusicEntity.type == .album {
                print("^^ Album")
                
                guard !sourceMusicEntity.appleMusicID.isEmpty else {
                    print("^^ No apple music ID")
                    continue
                }
                
                // Convert to MusicItem populated with related albums and with artists
                var sourceMusicItemRequest = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: MusicItemID(sourceMusicEntity.appleMusicID))
                sourceMusicItemRequest.properties = [.relatedAlbums, .artists]
                let result = try? await sourceMusicItemRequest.response()
                guard let sourceMusicItem = result?.items.first else {
                    print("^^ Resource request came up with no results")
                    continue
                }
                
                print("^^ Source album: \(sourceMusicItem.artistName) - \(sourceMusicItem.title)")
                print("^^ artists: \(sourceMusicItem.artists ?? [])")
                print("^^ related album: \(sourceMusicItem.relatedAlbums?.first?.title ?? ":(")")
                
                // Create variable to store the ID of the album we'll be recommending
                var recommendedAlbumID = ""
                
                // Find an album either from the related albums or from a related artist's albums
                if let relatedAlbums = sourceMusicItem.relatedAlbums, relatedAlbums.count > 0, let randomRelatedAlbum = relatedAlbums.randomElement() {
                    print("^^ Found related album")
                    
                    guard !matchExists(forAlbum: randomRelatedAlbum, inCollection: sources), !alreadyExistsInRecommendations(randomRelatedAlbum) else { 
                        print("^^ Album already exists in recs or collection")
                        continue
                    }
                    
                    recommendedAlbumID = randomRelatedAlbum.id.rawValue
                } else {
                    print("^^ No related albums")
                    
                    guard let artist = sourceMusicItem.artists?.first else { print("^^ No artist"); continue }
                    print("^^ Found an artist");
                    
                    // Populate with similar artists
                    let popArtist = try? await artist.with([.similarArtists])
                    
                    guard let relatedArtist = popArtist?.similarArtists?.randomElement() else {print("^^ No similar artists"); continue }
                    print("^^ Found related artist")
                    let populatedRelated = try? await relatedArtist.with([.albums])
                    guard let randomRelatedArtistAlbum = populatedRelated?.albums?.randomElement() else {print("^^ No album from related artist"); continue }
                    print("^^ Found an album from related artist");
                    recommendedAlbumID = randomRelatedArtistAlbum.id.rawValue
                }
                
                guard !recommendedAlbumID.isEmpty else {print("^^ No rec album ID"); continue }
                
                // Use ID for catalog resource request for MusicItem populated with artists and editorial
                var recommendedMusicItemRequest = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: MusicItemID(recommendedAlbumID))
                recommendedMusicItemRequest.properties = [.artists]
                let recReqResult = try? await recommendedMusicItemRequest.response()
                guard let recMusicItem = recReqResult?.items.first else {print("^^ Could not fetch populated album"); continue }
                
                // Get artist
                guard let recAlbumArtist = recMusicItem.artists?.first else {print("^^ Fetched album has no artist"); continue}
                
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
                
                print("^^ New rec album appended");
            } else if sourceMusicEntity.type == .song {
                print("^^ Song")
                
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
        
        print("^^ loop count \(attempts)")
        
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

