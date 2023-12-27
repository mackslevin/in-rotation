//
//  ActionViewController.swift
//  Rotation-iOSActionExtension
//
//  Created by Mack Slevin on 11/29/23.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import SwiftData

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        // Embed a SwiftUI view so that we don't have to lay this shit out in UIKit. Pass in model context and extension input to the SwiftUI view.
        
        let schema = Schema([
            MusicEntity.self,
            Tag.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, groupContainer: .identifier("group.com.johnslevin.Rotation"), cloudKitDatabase: .private("iCloud.com.johnslevin.Rotation"))
        
        let modelContainer = try? ModelContainer(for: MusicEntity.self, configurations: modelConfiguration)
        
        let contentView = MainView()
                    .environment(\.modelContext, modelContainer!.mainContext)
                    .environment(\.extensionContext, extensionContext)
        
        view = UIHostingView(rootView: contentView)
                view.isOpaque = true
                view.backgroundColor = .systemBackground
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
