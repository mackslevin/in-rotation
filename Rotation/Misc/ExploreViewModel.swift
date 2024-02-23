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
    case unableToFillRecommendations = "Unable to generate recommendations based on your collection. Please make sure your collection contains some songs and/or albums, at least a half dozen or so for best results. (Currently, playlists do not generate recommendations.)"
}


@Observable
class ExploreViewModel {
    var recommendationEntities: [RecommendationEntity] = []
    
    let amWrangler = AppleMusicWrangler()
    let amSearchWrangler = AppleMusicSearchWrangler()
//    let spotifyWrangler = SpotifyAPIWrangler()
    var recommendationsAreLoading = false
    
    func fillRecommendations(withSources sources: [MusicEntity]) async throws {
        guard !sources.isEmpty else {
            print("^^ no sources")
            throw ExploreError.unableToFillRecommendations
        }
        
        recommendationEntities = []
        recommendationsAreLoading = true
        
        var attempts = 0
        
        while attempts < 50 && recommendationEntities.count < 10 {
            attempts += 1
            let randomSource = sources.randomElement()!
            
            if let relatedAlbum = await findRelatedAlbum(for: randomSource),
               !matchExists(forAlbum: relatedAlbum, inCollection: sources),
                let recommendationEntity = await recommendationEntityFromAlbum(relatedAlbum, withSource: randomSource)
            {
                recommendationEntities.append(recommendationEntity)
            }
        }
        
        recommendationsAreLoading = false
        
        if recommendationEntities.count < 10 {
            print("^^ ran out of attempts: \(attempts)")
            throw ExploreError.unableToFillRecommendations
        }
    }
    
    func matchExists(forAlbum album: Album, inCollection collection: [MusicEntity]) -> Bool {
        for musicEntity in collection {
            if musicEntity.title == album.title && musicEntity.artistName == album.artistName {
                return true
            }
        }
        
        return false
    }
    
    func recommendationEntityFromAlbum(_ album: Album, withSource source: MusicEntity) async -> RecommendationEntity? {
        guard let populatedAlbum = try? await album.with([.artists]) else { return nil }
        
        var blurb = populatedAlbum.editorialNotes?.short
        if blurb == nil {
            blurb = populatedAlbum.editorialNotes?.standard
        }
        guard let artist = populatedAlbum.artists?.first else { return nil }
        guard let musicEntity = await amSearchWrangler.makeMusicEntity(from: populatedAlbum) else { return nil }
        
        return RecommendationEntity(musicEntity: musicEntity, recommendationSource: source, blurb: blurb, artist: artist)
    }
    
    func findRelatedAlbum(for source: MusicEntity) async -> Album? {
        guard let relatedAlbums = await getRelatedAlbums(for: source), !relatedAlbums.isEmpty else {
            return nil
        }
        
        var randomAlbum = relatedAlbums.randomElement()!
        var attempts = 0 // Set an upper limit to the amount of times we can try this.
        while attempts < 3 && alreadyExistsInRecommendations(randomAlbum) {
            attempts += 1
            randomAlbum = relatedAlbums.randomElement()!
        }
        
        if alreadyExistsInRecommendations(randomAlbum) {
            return nil
        } else {
            return randomAlbum
        }
    }
    
    func alreadyExistsInRecommendations(_ musicItem: MusicItem) -> Bool {
        for rec in recommendationEntities {
            if rec.musicEntity.appleMusicID == musicItem.id.rawValue {
                return true
            }
        }
        
        return false
    }
    
    func getRelatedAlbums(for musicEntity: MusicEntity) async -> [Album]? {
        var album: Album? = nil
        
        print("^^ getting related for \(musicEntity.title)")
        
        switch musicEntity.type {
            case .song:
                var song: Song? = nil
                if !musicEntity.appleMusicID.isEmpty, let foundSong = try? await amWrangler.findByAppleMusicID(musicEntity) {
                    song = foundSong as? Song
                } else if !musicEntity.isrc.isEmpty {
                    song = try? await amWrangler.findSongByISRC(musicEntity.isrc)
                }
                
                if let song = try? await song?.with([.albums]), let songAlbum = song.albums?.first {
                    album = songAlbum as Album
                } else {
                    return nil
                }
            case .album:
                if !musicEntity.appleMusicID.isEmpty, let foundAlbum = try? await amWrangler.findByAppleMusicID(musicEntity) {
                    album = foundAlbum as? Album
                } else if !musicEntity.upc.isEmpty {
                    album = try? await amWrangler.findAlbumByUPC(musicEntity.upc)
                }
            case .playlist:
                return nil
        }
        
        guard 
            let album,
            let populatedAlbum = try? await album.with([.relatedAlbums, .artists]),
            let relatedAlbums = populatedAlbum.relatedAlbums
        else {return nil }
        
        var albumsToReturn: [Album] = []
        
        if relatedAlbums.count > 0 {
            for alb in relatedAlbums {
                albumsToReturn.append(alb as Album)
            }
        } else if let artist = try? await populatedAlbum.artists?.first?.with([.similarArtists]), let similarArtists = artist.similarArtists, !similarArtists.isEmpty {
            let randomSimilarArtist = similarArtists.randomElement()!
            let populatedArtist = try? await randomSimilarArtist.with([.albums])
            if let albums = populatedArtist?.albums, !albums.isEmpty {
                for album in albums {
                    albumsToReturn.append(album)
                }
            }
        }

        return albumsToReturn
    }
}

