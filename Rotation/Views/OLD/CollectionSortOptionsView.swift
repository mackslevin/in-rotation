//
//  CollectionSortOptionsView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/17/23.
//

import SwiftUI

struct CollectionSortOptionsView: View {
    @Bindable var viewModel: CollectionViewModel
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var useGrid = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("View")
                    .padding(.bottom, 6)
                    .padding(.horizontal)
                    .padding(.top)
                    .font(Font.displayFont(ofSize: 18))
                    .foregroundStyle(.secondary)
                
                Picker("View", selection: $useGrid) {
                    Label("List", systemImage: "line.3.horizontal").tag(false)
                    Label("Grid", systemImage: "rectangle.grid.2x2").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                
                Text("Sort by...")
                    .padding(.bottom, 6)
                    .padding(.horizontal)
                    .padding(.top)
                    .font(Font.displayFont(ofSize: 18))
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 0) {
                    ForEach(CollectionSortCriteria.allCases, id: \.rawValue) { criteria in
                        Button {
                            withAnimation {
                                viewModel.sortCriteria = criteria
                                dismiss()
                            }
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    Group {
                                        if criteria == viewModel.sortCriteria {
                                            Text(criteria.rawValue).foregroundStyle(.primary).colorInvert()
                                        } else {
                                            Text(criteria.rawValue)
                                        }
                                    }
                                    .padding()
                                        
                                    Spacer()
                                }
                                
                                if criteria != viewModel.sortCriteria {
                                    Rectangle()
                                        .frame(height: 1)
                                        .opacity(0.2)
                                }
                            }
                            .tint(.primary)
                            .background {
                                if criteria == viewModel.sortCriteria {
                                    Rectangle().foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                        .bold(criteria == viewModel.sortCriteria)
                    }
                }
                
                Spacer()
            }
        }
        .background {
            Utility.customBackground(withColorScheme: colorScheme)
        }
    }
}

//#Preview {
//    CollectionSortOptionsView(viewModel: CollectionViewModel(), isShowingSortingOptions: .constant(true))
//}
