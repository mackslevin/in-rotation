//
//  TagDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/25/24.
//

import SwiftUI

struct TagDetailView: View {
    @Bindable var tag: Tag
    @State private var isShowingSymbolPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Button("", systemImage: tag.symbolName) {
                        isShowingSymbolPicker.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .font(.system(size: 48))
                    .foregroundColor(.primary)
                    
                    TextField("Title", text: $tag.title)
                        .font(.displayFont(ofSize: 32))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading) {
                        ForEach(tag.musicEntities ?? []) { musicEntity in
                            VStack {
                                musicEntity.image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                                
                                HStack {
                                    
                                    Spacer()
                                    Text(musicEntity.title)
                                        .font(.displayFont(ofSize: 18))
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding()
                                
                                
                            }
                            .padding()
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: Utility.defaultCorderRadius(small: true)))
                            
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle(tag.title)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $isShowingSymbolPicker) {
                    NavigationStack {
                        ScrollView {
                            SymbolPicker(symbolName: $tag.symbolName)
                                .padding()
                        }
                        .background {
                            Color.customBG.ignoresSafeArea()
                        }
                        .navigationTitle("Choose a Symbol")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close", systemImage: "xmark") {
                                    isShowingSymbolPicker.toggle()
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
}

//#Preview {
//    TagDetailView()
//}
