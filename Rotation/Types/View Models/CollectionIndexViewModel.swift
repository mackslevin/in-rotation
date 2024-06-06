//
//  CollectionIndexViewModel.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import Foundation
import Observation

@Observable
class CollectionIndexViewModel {
    var selectedEntityID: UUID?
    var shouldShowAddView = false
}
