//
//  PrimaryView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI



struct PrimaryView: View {
    @Environment(\.appleMusicAuthWrangler) var appleMusicAuthWrangler
    @State private var vm = PrimaryViewModel()
    @State private var tabViewStyle: any TabViewStyle = DefaultTabViewStyle()
    @State private var viewMode: ViewMode = .collection
    @State private var shouldShowNavigationShelf = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            
            // TODO: Figure out default selected tab thing. (Probably try and save ViewMode to UserDefaults)
            VStack(spacing: 0) {
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
            }
            .overlay(alignment: .bottom) {
                VStack() {
                    Button {
                        withAnimation(
                            .interactiveSpring(response: 0.4)
                        ) {
                            shouldShowNavigationShelf.toggle()
                        }
                    } label: {
                        ZStack {
                            Circle().foregroundStyle(Color.primary).opacity(0.001) // Circle w/ barely non-zero opacity, otherwise tap won't register consistently
                            Image(systemName: "chevron.up.2")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .rotationEffect(shouldShowNavigationShelf ? .degrees(180) : .degrees(0))
                                .opacity(0.5)
                        }
                        .frame(width: 44)
                        
                    }
                    .tint(.primary)
                    .padding(.bottom, shouldShowNavigationShelf ? 0 : 30)
                    .buttonStyle(PlainButtonStyle())
                    
                    Rectangle().foregroundStyle(.primary)
                        .frame(height: 1)
                        .opacity(shouldShowNavigationShelf ? 0.1 : 0)
                        .transition(.scale)
                }
                
            }
            
            NavigationShelf(shouldShowNavigationShelf: $shouldShowNavigationShelf, viewMode: $viewMode)
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
