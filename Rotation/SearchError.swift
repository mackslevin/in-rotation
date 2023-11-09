//
//  SearchError.swift
//  Rotation
//
//  Created by Mack Slevin on 11/8/23.
//

import Foundation

enum SearchError: Error, Equatable {
    case noSearchResponse, tracksUnavailable, badArtwork
    static func == (lhs: SearchError, rhs: SearchError) -> Bool {
        switch (lhs, rhs) {
            default:
                return true
        }
    }
}
