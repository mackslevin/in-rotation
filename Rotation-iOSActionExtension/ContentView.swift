//
//  ContentView.swift
//  Rotation-iOSActionExtension
//
//  Created by Mack Slevin on 11/29/23.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.extensionContext) var extensionContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query var musicEntities: [MusicEntity]
    
    @State private var url: URL? = nil
    @State private var musicURLWrangler = MusicURLWrangler()
    @State private var musicEntity: MusicEntity? = nil
    @State private var thereWasAnError = false
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let musicEntity {
                    HStack {
                        if let imageData = musicEntity.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage).resizable().scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 10)
                                .frame(width: 120)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(musicEntity.title)
                                .font(Font.displayFont(ofSize: 18))
                            Text(musicEntity.artistName)
                                .bold().foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    
                } else if thereWasAnError {
                    ContentUnavailableView("Cannot add to Rotation", systemImage: "eyes", description: Text("The cause is likely an invalid URL. Please try with a valid share link from Apple Music or Spotify."))
                    
                } else {
                    HStack { Spacer(); ProgressView(); Spacer() }
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel"){
                        dismiss()
                    }
                    .padding()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .bold()
                    .disabled(musicEntity == nil)
                    .padding()
                }
            }
            .padding()
            .background {
                Rectangle().ignoresSafeArea().foregroundStyle(colorScheme == .dark ? Color.clear : Color.orange)
                    .opacity(0.07)
            }
            .tint(.orange)
            .navigationTitle("Add to Rotation")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setURLFromExtensionContext()
            }
            .onChange(of: url) { oldValue, newValue in
                if let url {
                    Task {
                        do {
                            musicEntity = try await musicURLWrangler.musicEntityFromURL(url)
                        } catch {
                            print(error)
                            thereWasAnError = true
                        }
                    }
                } else {
                    thereWasAnError = true
                }
            }
        }
        
    }
    
    func save() {
        if let musicEntity {
            modelContext.insert(musicEntity)
            dismiss()
        }
    }
    
    func dismiss() {
        extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    func setURLFromExtensionContext() {
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let provider = inputItem.attachments?.first {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier) { (item, error) in
                    if let nsURL = item, let incomingURL = nsURL as? URL {
                        url = incomingURL
                    }
                }
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
