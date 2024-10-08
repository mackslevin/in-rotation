//
//  RotationApp.swift
//  Rotation
//
//  Created by Mack Slevin on 11/7/23
//

import SwiftUI 
import SwiftData

@main
struct RotationApp: App {
    @StateObject private var iapWrangler = IAPWrangler()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MusicEntity.self,
            Tag.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, groupContainer: .identifier("group.com.johnslevin.Rotation"), cloudKitDatabase: .private("iCloud.com.johnslevin.Rotation"))

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("^^ Could not create ModelContainer: \(error)")
        }
    }()
    
    var appleMusicAuthWrangler = AppleMusicAuthWrangler()
    
    @State private var amSearchWrangler = AppleMusicSearchWrangler.shared
    @State private var amWrangler = AppleMusicWrangler()

    var body: some Scene {
        WindowGroup {
            PrimaryView()
        }
        .modelContainer(sharedModelContainer)
        .environment(\.appleMusicAuthWrangler, appleMusicAuthWrangler)
        .environment(amWrangler)
        .environment(amSearchWrangler)
        .environmentObject(iapWrangler)
        
    }
}
