//
//  PostSortPinnedOptionsView.swift
//  Mlem
//
//  Created by Sjmarf on 17/09/2023.
//

import SwiftUI

struct PostSortPinnedOptionsView: View {
    @EnvironmentObject var pinnedViewOptions: PinnedViewOptionsTracker
    
    var body: some View {
        Form {
            Section {
                ForEach(PostSortType.outerTypes, id: \.self) { type in
                    let isSelected = pinnedViewOptions.pinned.sortTypes.contains(type)
                    Button {
                        if isSelected {
                            pinnedViewOptions.pinned.sortTypes.remove(type)
                        } else {
                            pinnedViewOptions.pinned.sortTypes.insert(type)
                        }
                    } label: {
                        label(type.label, systemImage: type.iconName, isSelected: isSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section {
                ForEach(PostSortType.topTypes, id: \.self) { type in
                    let isSelected = pinnedViewOptions.pinned.topSortTypes.contains(type)
                    Button {
                        if isSelected {
                            pinnedViewOptions.pinned.topSortTypes.remove(type)
                        } else {
                            pinnedViewOptions.pinned.topSortTypes.insert(type)
                        }
                    } label: {
                        label(type.label, systemImage: type.iconName, isSelected: isSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
            Section {
                ForEach(PostViewOption.allCases, id: \.self) { type in
                    let isSelected = pinnedViewOptions.pinned.options.contains(type)
                    Button {
                        if isSelected {
                            pinnedViewOptions.pinned.options.remove(type)
                        } else {
                            pinnedViewOptions.pinned.options.insert(type)
                        }
                    } label: {
                        label(type.label, systemImage: type.iconName, isSelected: isSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Pinned Options")
        .onDisappear(perform: pinnedViewOptions.save)
    }
    
    @ViewBuilder
    func label(_ title: String, systemImage: String, isSelected: Bool) -> some View {
        HStack {
            FormLabel(title: title, iconName: systemImage, imageScale: .medium)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .imageScale(.medium)
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
            }
        }
        .animation(.easeOut(duration: 0.1), value: isSelected)
        .contentShape(Rectangle())
    }
}
