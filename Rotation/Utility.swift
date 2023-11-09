//
//  Utility.swift
//  Rotation
//
//  Created by Mack Slevin on 11/8/23.
//

import Foundation
import SwiftUI

struct Utility {

    
    @MainActor
    static func dismissKeyboard() {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.endEditing(true)
    }
}
