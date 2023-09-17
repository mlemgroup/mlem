//
//  PostSortDefaultMenu.swift
//  Mlem
//
//  Created by Sjmarf on 17/09/2023.
//

import SwiftUI

struct PostSortDefaultPickerView: View {
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    
    var body: some View {
        Form {
            Picker("Default post sort mode", selection: $defaultPostSorting) {
                ForEach(PostSortType.allCases, id: \.self) { type in
                    FormLabel(title: type.description, iconName: type.iconName, imageScale: .medium)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .navigationTitle("Default Sort Mode")
    }
}
