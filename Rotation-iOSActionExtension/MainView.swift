//
//  MainView.swift
//  Rotation-iOSActionExtension
//
//  Created by Mack Slevin on 12/26/23.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import StoreKit

struct MainView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.extensionContext) var extensionContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query var musicEntities: [MusicEntity]
    
    @State private var url: URL? = nil
    @State private var musicURLWrangler = MusicURLWrangler()
    @State private var amWrangler = AppleMusicWrangler()
//    @State private var spotifyWrangler = SpotifyAPIWrangler()
    @State private var musicEntity: MusicEntity? = nil
    @State private var thereWasAnError = false
    
    @State private var selectedTags: [Tag] = []
    @State private var isShowingTagToggler = false
    @State private var isShowingNotesEditor = false
    @State private var isShowingSuccessConfirmation = false
    @State private var successMessage: String? = nil
    
    @State private var source: URLSource = .unknown
    
    @State private var userHasPremiumAccess = false
    @State private var isShowingPaywallSheet = false
    
    let accentColor = Color.orange
    
    var body: some View {
        
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                Spacer()
                Text("In Rotation")
                    .foregroundStyle(accentColor)
                    .font(.displayFont(ofSize: 24))
                
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .bold()
                }
            }
            ScrollView {
                
                if let musicEntity {
                    
                    // MARK: MUSIC ENTITY INFO
                    HStack {
                        if let data = musicEntity.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage).resizable().scaledToFill()
                                .frame(width: 150)
                                .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                                
                        }
                        
                        VStack(alignment: .leading) {
                            Text(musicEntity.title)
                                .lineLimit(3)
                                .font(.displayFont(ofSize: 24))
                            Text(musicEntity.artistName)
                                .lineLimit(2)
                            if let year = musicEntity.releaseYear() {
                                Text(String(year))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    VStack(spacing: 8) {
                    // MARK: COPY BUTTON
                    if source == .spotify && !musicEntity.appleMusicURLString.isEmpty {
                        Button {
                            handleCopy(withURLString: musicEntity.appleMusicURLString)
                        } label: {
                            HStack {
                                Spacer()
                                Label("Copy Apple Music URL", systemImage: "link")
                                Spacer()
                            }
                        }
                        .buttonStyle(.bordered).fontWeight(.medium)
                    } else if source == .appleMusic && !musicEntity.spotifyURLString.isEmpty {
                        Button {
                            handleCopy(withURLString: musicEntity.spotifyURLString)
                        } label: {
                            HStack {
                                Spacer()
                                Label("Copy Spotify URL", systemImage: "link")
                                Spacer()
                            }
                        }
                        .buttonStyle(.bordered).fontWeight(.medium)
                    }
                    
                    // MARK: TAGS
                    if !selectedTags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Tags")
                                    .fontWeight(.semibold)
                                Spacer()
                                Button {
                                    isShowingTagToggler = true
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                            }
                            
                            Text(selectedTags.map({$0.title}).joined(separator: ", "))
                                .italic()
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: false))
                                .foregroundStyle(.regularMaterial)
                        }
                    } else {
                        Button {
                            isShowingTagToggler = true
                        } label: {
                            Label("Add Tags", systemImage: "tag")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .fontWeight(.medium)
                    }
                    
                    
                    // MARK: NOTES
                    if !musicEntity.notes.isEmpty {
                        MusicEntityNotesBlock(musicEntity: musicEntity)
                    } else {
                        Button {
                            isShowingNotesEditor = true
                        } label: {
                            Label("Add Notes", systemImage: "note.text.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .fontWeight(.medium)
                    }
                    
                    // MARK: SAVE BUTTON
                    Button {
                        handleSave()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Save to Collection", systemImage: "plus")
                                .bold()
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    }
                    
                } else if thereWasAnError {
                    InvalidURLView(url: url)
                } else {
                    HStack { Spacer(); ProgressView(); Spacer() }
                }
            
            }
            
        }
        .padding()
        .tint(accentColor)
        .background {
            Utility.customBackground(withColorScheme: colorScheme)
        }
        .overlay {
            if isShowingSuccessConfirmation {
                Rectangle()
                    .foregroundStyle(.thinMaterial)
                    .overlay(alignment: .center) {
                        VStack {
                            Image(systemName: "checkmark.circle.fill").resizable().scaledToFit()
                                .frame(width: 150)
                            if let successMessage {
                                Text(successMessage)
                                    .font(.displayFont(ofSize: 24))
                            }
                        }
                        .foregroundStyle(accentColor)
                    }
            }
        }
        .onAppear {
            print("^^ appear")
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
                
                if let urlSource = try? musicURLWrangler.determineSource(ofURL: url) {
                    source = urlSource
                }
            } else {
                thereWasAnError = true
            }
        }
        .sheet(isPresented: $isShowingTagToggler) {
            TagTogglerView(selectedTags: $selectedTags)
                .tint(accentColor)
        }
        .sheet(isPresented: $isShowingNotesEditor) {
            if let musicEntity {
                NotesEditorView(musicEntity: musicEntity)
                    .tint(accentColor)
            }
        }
        .sheet(isPresented: $isShowingPaywallSheet, content: {
            VStack {
                EntityLimitReachedView()
                Spacer()
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    isShowingPaywallSheet = false
                } label: {
                    Image(systemName: "xmark")
                        .bold()
                }
            }
            .padding()
            .background { Utility.customBackground(withColorScheme: colorScheme) }
            .tint(accentColor)
        })
        .currentEntitlementTask(for: Utility.premiumUnlockProductID) { state in
            switch state {
                case .loading:
                    print("^^ state is loading")
                case .failure(let error):
                    print("^^ state failed, error is \(error)")
                case .success(let transaction):
                    print("^^ state is success")
                    userHasPremiumAccess = transaction != nil
                @unknown default:
                    fatalError()
            }
        }
        .onChange(of: musicEntity) { oldValue, newValue in
            print("^^ changed")
            if let me = newValue {
                print("^^ new me")
                if me.appleMusicURLString.isEmpty {
                    Task {
                        do {
                            try await amWrangler.fillInAppleMusicInfo(me)
                        } catch {
                            print("^^ errrrrrr - \(error.localizedDescription)")
                        }
                    }
                }
                
//                if me.spotifyURLString.isEmpty {
//                    Task {
//                        if let urlStr = try? await spotifyWrangler.findMatch(forMusicEntity: me) {
//                            me.spotifyURLString = urlStr
//                        }
//                    }
//                }
            }
        }
    }
    
    func dismiss() {
        extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    func setURLFromExtensionContext() {
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let provider = inputItem.attachments?.first {
                provider.loadItem(forTypeIdentifier: UTType.url.identifier) { (item, error) in
                    guard error == nil else {
                        thereWasAnError = true
                        return
                    }
                    
                    if let nsURL = item, let incomingURL = nsURL as? URL {
                        url = incomingURL
                        return
                    }
                }
            }
        }
    }
    
    func handleCopy(withURLString urlString: String) {
        UIPasteboard.general.string = urlString
        successMessage = "Copied!"
        
        withAnimation {
            isShowingSuccessConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isShowingSuccessConfirmation = false
                successMessage = nil
            }
        }
    }
    
    func handleSave() {
        guard let musicEntity else { return }
        guard musicEntities.count < Utility.maximumFreeEntities || userHasPremiumAccess else {
            isShowingPaywallSheet = true
            return
        }
        
        if !selectedTags.isEmpty {
            musicEntity.tags = selectedTags
        }
        
        
        print("^^ Saving \(musicEntity.title) by \(musicEntity.artistName)")
        modelContext.insert(musicEntity)
        
        
        
        successMessage = "Saved!"
        withAnimation {
            isShowingSuccessConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isShowingSuccessConfirmation = false
                successMessage = nil
                dismiss()
            }
        }
    }
}

//#Preview {
//    MainView()
//}
