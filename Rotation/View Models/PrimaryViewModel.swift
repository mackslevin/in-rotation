//
//  PrimaryViewModel.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI
import Observation

@Observable
class PrimaryViewModel {
    var selectedTab = 1
    var shouldShowWelcomeView = false
    var shouldShowNavigationShelf = false
    var viewMode: ViewMode = .collection
    
    init() {
        if let defaultScreen = UserDefaults.standard.value(forKey: StorageKeys.defaultScreen.rawValue) as? String {
            for viewMode in ViewMode.allCases {
                if viewMode.rawValue.lowercased() == defaultScreen.lowercased() {
                    self.viewMode = viewMode
                    break
                }
            }
        }
        
        if let shouldShowWelcomeView = UserDefaults.standard.value(forKey: StorageKeys.shouldShowWelcomeView.rawValue) as? Bool {
            self.shouldShowWelcomeView = shouldShowWelcomeView
        }
    }
    
    func setUpAppearance() {
        setUpNavBar()
    }
    
    func markWelcomeViewAsSeen() {
        UserDefaults.standard.setValue(false, forKey: StorageKeys.shouldShowWelcomeView.rawValue)
    }
    
    private func setUpNavBar() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont(name: "PPPierSans-Bold", size: 38)!,
            .foregroundColor: UIColor(Color.accentColor)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(name: "PPPierSans-Bold", size: 20)!,
            .foregroundColor: UIColor(Color.accentColor)
        ]
    }
}
