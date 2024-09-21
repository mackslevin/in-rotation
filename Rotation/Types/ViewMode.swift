//
//  ViewMode.swift
//  Rotation
//
//  Created by Mack Slevin on 9/21/24.
//
import SwiftUI

enum ViewMode: String, CaseIterable {
    case collection = "Collection"
    case tags = "Tags"
    case explore = "Explore"
    case settings = "Settings"

    var sfSymbol: Image {
        switch self {
            case .collection:
                Image(systemName: "list.bullet")
            case .tags:
                Image(systemName: "tag")
            case .explore:
                Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
            case .settings:
                Image(systemName: "gear")
        }
    }
}
