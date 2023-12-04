//
//  EnvironmentValues-Ext.swift
//  Rotation
//
//  Created by Mack Slevin on 11/29/23.
//

import SwiftUI

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
}
