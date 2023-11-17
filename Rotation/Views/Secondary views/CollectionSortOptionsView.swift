//
//  CollectionSortOptionsView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/17/23.
//

import SwiftUI

struct CollectionSortOptionsView: View {
    @Bindable var viewModel: CollectionViewModel
    @Binding var isShowingSortingOptions: Bool
    
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
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
                                isShowingSortingOptions = false
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
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .opacity(0.2)
                            }
                            
                            .tint(.primary)
                            .background {
                                if criteria == viewModel.sortCriteria {
                                    Rectangle().foregroundStyle(.tint)
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

#Preview {
    CollectionSortOptionsView(viewModel: CollectionViewModel(), isShowingSortingOptions: .constant(true))
}
