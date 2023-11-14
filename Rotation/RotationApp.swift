//
//  RotationApp.swift
//  Rotation
//
//  Created by Mack Slevin on 11/7/23.
//

import SwiftUI
import SwiftData

@main
struct RotationApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MusicEntity.self,
            Tag.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {

            fatalError("^^ Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ExternalMusicSearchView()
        }
        .modelContainer(sharedModelContainer)
        
    }
}
