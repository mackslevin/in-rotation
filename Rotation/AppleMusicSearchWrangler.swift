//
//  AppleMusicSearchWrangler.swift
//  Rotation
//
//  Created by Mack Slevin on 11/8/23.
//

import SwiftUI
import Observation
import MusicKit

@Observable
class AppleMusicSearchWrangler {
    var albumResults: [Album] = []
    var songResults: [Song] = []
    var playlistResults: [Playlist] = []
    
    var searchError: SearchError? = nil
    
    @MainActor
    func search(withTerm term: String) async {
        guard !term.isEmpty else {
            reset()
            return
        }
        
        var request = MusicCatalogSearchRequest(term: term, types: [Album.self, Song.self, Playlist.self])
        request.limit = 3
        request.offset = 0
        
        do {
            let response = try await request.response()
            
            reset()
            
            albumResults = Array<Album>(response.albums)
            songResults = Array<Song>(response.songs)
            playlistResults = Array<Playlist>(response.playlists)
        } catch {
            searchError = .noSearchResponse
            return
        }
        
        print("^^ albums: \(albumResults.count)")
    }
    
    @MainActor
    func reset() {
        albumResults = []
        songResults = []
        playlistResults = []
        searchError = nil
    }
    
    func resultsExist() -> Bool {
        return !albumResults.isEmpty || !songResults.isEmpty || !playlistResults.isEmpty
    }
    
    private func getTracksForAlbum(_ album: Album) async -> [Track] {
        let id = album.id
        var request = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: id)
        request.properties = [.tracks]
        request.limit = 1
        
        do {
            let response = try await request.response()
            if let tracks = response.items.first?.tracks {
                return Array<Track>(tracks)
            } else {
                searchError = .tracksUnavailable
            }
        } catch {
            searchError = .tracksUnavailable
        }
        
        return []
    }
    
    func getSongTitlesDurationAndArtwork(forAlbum album: Album) async -> ([String], TimeInterval, Data?) {
        let tracks = await getTracksForAlbum(album)
        
        var albumDuration: TimeInterval = 0
        var titles: [String] = []
        
        var dontTrustTheDuration = false
        
        for track in tracks {
            if let trackDuration = track.duration {
                albumDuration += trackDuration
            } else {
                dontTrustTheDuration = true
            }
            
            titles.append(track.title)
        }
        
        if dontTrustTheDuration {
            albumDuration = .zero
        }
        
        var imageData: Data? = nil
        if let artwork = album.artwork, let url = artwork.url(width: 600, height: 600) {
            do {
                imageData = try Data(contentsOf: url)
            } catch {
                searchError = .badArtwork
            }
        }
        
        return (titles, albumDuration, imageData)
    }
}
