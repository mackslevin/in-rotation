//
//  PrimaryView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI

enum ViewMode {
    case collection, tags, explore, settings
}

struct PrimaryView: View {
    @Environment(\.appleMusicAuthWrangler) var appleMusicAuthWrangler
    @State private var vm = PrimaryViewModel()
    @State private var tabViewStyle: any TabViewStyle = DefaultTabViewStyle()
    @State private var viewMode: ViewMode = .collection
    @State private var shouldShowTabView = true
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            
            // TODO: Figure out default selected tab thing. (Probably try and save ViewMode to UserDefaults)
            
            switch viewMode {
                case .collection:
                    CollectionIndexView()
                case .tags:
                    TagsIndexView()
                case .explore:
                    ExploreView()
                case .settings:
                    SettingsView()
            }
            
            if shouldShowTabView {
                ZStack {
                    Rectangle().foregroundStyle(.accent).opacity(0.3)
                    
                    VStack {
                        HStack(alignment: .bottom) {
                            Button {
                                withAnimation {
                                    viewMode = .collection
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "list.bullet").font(.title2).bold()
                                    Text("Collection").font(.caption2).fontWeight(.medium)
                                }
                            }
                            .tint(viewMode == .collection ? .accentColor : .secondary)
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    viewMode = .tags
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "tag").font(.title2).bold()
                                    Text("Tags").font(.caption2).fontWeight(.medium)
                                }
                            }
                            .tint(viewMode == .tags ? .accentColor : .secondary)
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    viewMode = .explore
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled").font(.title2).bold()
                                    Text("Collection").font(.caption2).fontWeight(.medium)
                                }
                            }
                            .tint(viewMode == .explore ? .accentColor : .secondary)
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    viewMode = .settings
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "gear").font(.title2).fontWeight(.bold)
                                    Text("Settings").font(.caption2).fontWeight(.medium)
                                }
                            }
                            .tint(viewMode == .settings ? .accentColor : .secondary)
                            
                        }
                        .frame(maxWidth: 500)
                        .padding(.horizontal, 30)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    
                }
                .frame(height: 90)
            }
        }
        .ignoresSafeArea()
        .task {
            await appleMusicAuthWrangler.requestMusicAuth()
            await appleMusicAuthWrangler.getMusicSubscriptionUpdates()
        }
        .onAppear {
            vm.setUpAppearance()
        }
        .sheet(isPresented: $vm.shouldShowWelcomeView, content: {
            WelcomeView()
                .onDisappear {
                    vm.markWelcomeViewAsSeen()
                }
        })
        
        
    }
    
}

//#Preview {
//    
//    PrimaryView()
//        .environment(AppleMusicWrangler())
//}
