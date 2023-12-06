//
//  EnvironmentValues-Ext.swift
//  Rotation
//
//  Created by Mack Slevin on 11/29/23.
//

import SwiftUI
import Observation

// This is used for injecting the extension context from ActionViewController into a SwiftUI view. See ActionViewController.viewDidLoad.
extension EnvironmentValues {
    private struct ExtensionContext: EnvironmentKey {
        static var defaultValue: NSExtensionContext?
    }

    /// The `.extensionContext` of an app extension view controller.
    var extensionContext: NSExtensionContext? {
        get { self[ExtensionContext.self] }
        set {
            self[ExtensionContext.self] = newValue
        }
    }
    
    var appleMusicAuthWrangler: AppleMusicAuthWrangler {
        get { self[AppleMusicAuthWranglerKey.self] }
        set { self[AppleMusicAuthWranglerKey.self] = newValue }
    }
}

struct AppleMusicAuthWranglerKey: EnvironmentKey {
    static let defaultValue: AppleMusicAuthWrangler = .init() // Provide a default value
}
