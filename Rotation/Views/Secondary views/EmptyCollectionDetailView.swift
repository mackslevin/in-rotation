import SwiftUI
import SwiftData

struct EmptyCollectionDetailView: View {
    @Binding var shouldShowAddView: Bool
    @Query var musicEntities: [MusicEntity]
    @State private var isPortrait = false
    
    var body: some View {
        VStack(spacing: 40) {
            
            Image(systemName: "opticaldisc").resizable().scaledToFit()
                .frame(width: 200)
                .foregroundStyle(MeshGradient(width: 3, height: 3, points: [
                    .init(0, 0), .init(0.5, 0), .init(1, 0),
                    .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                    .init(0, 1), .init(0.5, 1), .init(1, 1)
                ], colors: [
                    .accent, .accent, .accent,
                    .accent, .secondary, .white,
                    .accent, .accent, .cyan
                ]))
            
            
            if musicEntities.isEmpty {
                VStack {
                    Text("It's so quiet!")
                        .font(.displayFont(ofSize: 36))
                    Text("Add some music to your collection to get started.")
                }
                .foregroundStyle(.secondary)
                
                Button("Search Music", systemImage: "magnifyingglass") {
                    shouldShowAddView.toggle()
                }
                .tint(Color.accent.gradient)
                .buttonStyle(.borderedProminent)
                .bold()
            } else {
                
                VStack {
                    Text("Nothing Selected")
                        .font(.displayFont(ofSize: 36))
                        .foregroundStyle(.secondary)
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        if isPortrait  {
                            Text("Toggle the sidebar \(Image(systemName: "sidebar.left")) to browse your collection")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            isPortrait = UIDevice.current.orientation == .portrait
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            
            isPortrait = UIDevice.current.orientation == .portrait
            
            
            print("^^ orientation changed")
        }
    }
}

#Preview {
    NavigationStack {
        HStack {
            Spacer()
            VStack {
                Spacer()
                EmptyCollectionDetailView(shouldShowAddView: .constant(false))
                
                Spacer()
            }
            Spacer()
        }
        .navigationTitle("Something")
        .background { Color.customBG.ignoresSafeArea() }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
