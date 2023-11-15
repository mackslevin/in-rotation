//
//  TagDetailView.swift
//  Rotation
//
//  Created by Mack Slevin on 11/14/23.
//

import SwiftUI
import SwiftData

struct TagDetailView: View {
    @Bindable var tag: Tag
    var body: some View {
        Text(tag.title)
    }
}
//
//#Preview {
//    TagDetailView()
//}
