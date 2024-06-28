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
    var shouldShowWelcomeView = true
    
    init() {
        if let defaultScreen = UserDefaults.standard.value(forKey: StorageKeys.defaultScreen.rawValue) as? DefaultScreen {
            switch defaultScreen {
                case .collection:
                    selectedTab = 1
                case .tags:
                    selectedTab = 2
                case .explore:
                    selectedTab = 3
            }
        }
        
        if let shouldShowWelcomeView = UserDefaults.standard.value(forKey: StorageKeys.shouldShowWelcomeView.rawValue) as? Bool {
            self.shouldShowWelcomeView = shouldShowWelcomeView
        }
    }
    
    func setUpAppearance() {
        setUpNavBar()
        setUpTabBar()
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
    
    private func setUpTabBar() {
        UITabBar.appearance().backgroundColor = UIColor(Color.customBG)
    }
}
