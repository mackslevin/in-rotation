//
//  AddFromURLView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/17/23.
//

import SwiftUI

struct AddFromURLView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var urlString = ""
    @State private var musicURLWrangler = MusicURLWrangler()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField("URL", text: $urlString)
                        .textFieldStyle(.roundedBorder) // This is something that I am typing into this here computer. The cat loves this stuff.
                        .onSubmit {
                            if let url = URL(string: urlString) {
                                Task {
                                    do {
                                        let musicEntity = try await musicURLWrangler.musicEntityFromURL(url)
                                        modelContext.insert(musicEntity)
                                    } catch {
                                        print(error)
                                    }
                                    
                                }
                            } else {
                                print("^^ bad url")
                            }
                        }
                    
                    Spacer()
                }
                .navigationTitle("Add from URL")
                .padding()
                
            }
            .background {
                Utility.customBackground(withColorScheme: colorScheme)
            }
        }
    }
}

#Preview {
    AddFromURLView()
}
