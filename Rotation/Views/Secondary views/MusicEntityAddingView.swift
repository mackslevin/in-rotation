//
//  MusicSearchEntityView.swift
//  Rotation
//
//  Created by Mack Slevin on 12/28/23.
//

import SwiftUI
import SwiftData

struct MusicEntityAddingView: View {
    @Bindable var musicEntity: MusicEntity
    let completion: () -> Void
    
    @Environment(\.modelContext) var modelContext
    
    @Query var allMusicEntities: [MusicEntity]
    
    @State private var selectedTags: [Tag] = []
    @State private var isShowingTagToggler = false
    @State private var isShowingNotesEditor = false
    @State private var userHasPremiumAccess = false
    @State private var isShowingPaywallSheet = false
    
    var body: some View {
        VStack {
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
        .sheet(isPresented: $isShowingTagToggler) {
            TagTogglerView(selectedTags: $selectedTags)
        }
        .sheet(isPresented: $isShowingNotesEditor) {
            NotesEditorView(musicEntity: musicEntity)
        }
        .sheet(isPresented: $isShowingPaywallSheet) {
            IAPPaywallView()
        }
    }
    
    func handleSave() {
        guard allMusicEntities.count < Utility.maximumFreeEntities || userHasPremiumAccess else {
            isShowingPaywallSheet = true
            return
        }
        
        musicEntity.tags = selectedTags
        modelContext.insert(musicEntity)
        completion()
    }
}

//#Preview {
//    MusicEntityAddingView()
//}
