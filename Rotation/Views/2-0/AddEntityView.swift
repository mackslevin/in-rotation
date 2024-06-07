//
//  AddEntityView.swift
//  Rotation
//
//  Created by Mack Slevin on 6/6/24.
//

import SwiftUI

struct AddEntityView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var vm = AddEntityViewModel()
    
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search...", text: $vm.searchText)
                    .textFieldStyle(.roundedBorder)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", action: { dismiss() })
                }
            }
            .padding()
            .navigationTitle("Add Music")
            .background { Color.customBG.ignoresSafeArea() }
        }
    }
}

#Preview {
//    AddEntityView()
    PrimaryView()
        .modelContainer(for: MusicEntity.self)
}
