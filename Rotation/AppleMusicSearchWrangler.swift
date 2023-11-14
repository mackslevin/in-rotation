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
    var isLoading = false
    
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
    
    private func getTracksForPlaylist(_ playlist: Playlist) async -> [Track] {
        let id = playlist.id
        var request = MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: id)
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
    
    func makeMusicEntity(from item: MusicItem) async -> MusicEntity? {
        isLoading = true
        
        var titles: [String] = []
        var duration: TimeInterval = .zero
        var imageData: Data? = nil
        
        if let song = item as? Song {
            titles = [song.title]
            duration = song.duration ?? .zero
            if let url = song.artwork?.url(width: 600, height: 600) {
                do {
                    imageData = try Data(contentsOf: url)
                } catch {
                    searchError = .badArtwork
                }
            }
            
            isLoading = false
            
            return MusicEntity(title: song.title, artistName: song.artistName, releaseDate: song.releaseDate ?? .distantFuture, numberOfTracks: 1, songTitles: titles, duration: duration, imageData: imageData, type: .song, isrc: song.isrc ?? "", appleMusicURLString: song.url?.absoluteString ?? "")
        } else if let album = item as? Album {
            let tracks = await getTracksForAlbum(album)
            var dontTrustTheDuration = false
            for track in tracks {
                if let trackDuration = track.duration {
                    duration += trackDuration
                } else {
                    dontTrustTheDuration = true
                }
                titles.append(track.title)
                if let url = album.artwork?.url(width: 600, height: 600) {
                    do {
                        imageData = try Data(contentsOf: url)
                    } catch {
                        searchError = .badArtwork
                    }
                }
            }
            if dontTrustTheDuration { duration = .zero }
            
            print("^^ Album UPC: \(album.upc ?? "N/A")")
            
            isLoading = false
            return MusicEntity(title: album.title, artistName: album.artistName, releaseDate: album.releaseDate ?? .distantFuture, numberOfTracks: album.trackCount, songTitles: titles, duration: duration, imageData: imageData, type: .album, upc: album.upc ?? "", appleMusicURLString: album.url?.absoluteString ?? "")
        } else if let playlist = item as? Playlist {
            let tracks = await getTracksForPlaylist(playlist)
            var dontTrustTheDuration = false
            for track in tracks {
                if let trackDuration = track.duration {
                    duration += trackDuration
                } else {
                    dontTrustTheDuration = true
                }
                titles.append(track.title)
                if let url = playlist.artwork?.url(width: 600, height: 600) {
                    do {
                        imageData = try Data(contentsOf: url)
                    } catch {
                        searchError = .badArtwork
                    }
                }
            }
            if dontTrustTheDuration { duration = .zero }
            
            isLoading = false
            return MusicEntity(title: playlist.name, artistName: playlist.curatorName ?? "N/A", releaseDate: playlist.lastModifiedDate ?? .distantFuture, numberOfTracks: tracks.count, songTitles: titles, duration: duration, imageData: imageData, type: .playlist)
        }
        
        isLoading = false
        return nil
    }
}
