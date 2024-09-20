import SwiftUI
import SwiftData

struct NoTagsSelectedView: View {
    @Binding var shouldShowAddView: Bool
    @Query var tags: [Tag]
    @State private var isPortrait = false
    
    var body: some View {
        VStack(spacing: 40) {
            
            Image(systemName: "tag.slash").resizable().scaledToFit()
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
            
            
            if tags.isEmpty {
                VStack {
                    Text("You haven't made any tags yet!")
                        .font(.displayFont(ofSize: 36))
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.secondary)
                
                Button("Add a Tag", systemImage: "plus") {
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
                            Text("Toggle the sidebar \(Image(systemName: "sidebar.left")) to browse tags")
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
                NoTagsSelectedView(shouldShowAddView: .constant(false))
                Spacer()
            }
            Spacer()
        }
        .navigationTitle("Something")
        .background { Color.customBG.ignoresSafeArea() }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
