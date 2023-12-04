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
    @State private var selectedTags: [Tag] = []
    @State private var isShowingTagToggler = false
    @State private var isShowingNotesEditor = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let musicEntity {
                        
                            if let imageData = musicEntity.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage).resizable().scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 10)
                            }
                            
                            VStack() {
                                Text(musicEntity.title)
                                    .font(Font.displayFont(ofSize: 18))
                                Text(musicEntity.artistName)
                                    .bold().foregroundStyle(.secondary)
                            }
                            .multilineTextAlignment(.center)
                        
                        
                        Group {
                            if selectedTags.isEmpty {
                                Button("Add tags..."){ isShowingTagToggler = true }
                            } else {
                                VStack {
                                    Text("Tags").fontWeight(.semibold)
                                    
                                    HStack {
                                        ForEach(selectedTags) { tag in
                                            ZStack {
                                                Circle()
                                                    .foregroundStyle(.tint)
                                                    .frame(width: 30)
                                                Image(systemName: tag.symbolName)
                                                    .resizable().scaledToFit()
                                                    .foregroundStyle(.white)
                                                    .frame(maxWidth: 20, maxHeight: 20)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: 150)
                                    
                                    Button("Edit tags...") { isShowingTagToggler = true }
                                }
                                
                            }
                        }
                        .padding(.vertical)
                        
                        Group {
                            if !notes.isEmpty {
                                VStack {
                                    Text("Notes").fontWeight(.semibold)
                                    Text(notes)
                                        .foregroundStyle(.secondary)
                                        .italic()
                                    
                                    Button("Edit notes...") { isShowingNotesEditor = true }
                                }
                            } else {
                                Button("Add notes...") { isShowingNotesEditor = true }
                            }
                        }
                        .padding(.vertical)
                        
                    } else if thereWasAnError {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Unable to import 😞")
                                .font(Font.displayFont(ofSize: 32))
                                .foregroundStyle(.tint)
                            
                            if let url {
                                Text("The following URL could not be matched with a valid Apple Music or Spotify item:")
                                Text(url.absoluteString)
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(.secondary)
                                
                                
                                Text("Please try again with a URL that looks more like one of these:")
                                Text("\("https://open.spotify.com/album/6gWz09raxjmq1EMIPcbnFy?si=GOAEo3tfSWS01OH7yHAI2g")")
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(.secondary)
                                Text("\("https://music.apple.com/us/album/hard-to-be/718735084?i=718735089")")
                                    .fontDesign(.monospaced)
                                    .foregroundStyle(.secondary)
                            }
                            
                        }
                        
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
            }
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
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
            .sheet(isPresented: $isShowingTagToggler) {
                TagTogglerView(selectedTags: $selectedTags)
            }
            .sheet(isPresented: $isShowingNotesEditor) {
                if let musicEntity {
                    NotesEditorView(musicEntity: musicEntity)
                }
            }
        }
    }
    
    func save() {
        if let musicEntity {
            if !selectedTags.isEmpty {
                musicEntity.tags = selectedTags
            }
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
