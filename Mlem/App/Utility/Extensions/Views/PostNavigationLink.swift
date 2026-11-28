//
//  PostNavigationLink.swift
//  Mlem
//
//  Created by mdhiggins on 2026-11-26.
//

import SwiftUI
import Theming

struct PostNavigationLink<Label: View>: View {
    @Environment(NavigationLayer.self) private var navigation
    @Environment(\.palette) private var palette

    let page: NavigationPage
    @ViewBuilder let label: () -> Label

    init(_ page: NavigationPage, @ViewBuilder label: @escaping () -> Label) {
        self.page = page
        self.label = label
    }

    var body: some View {
        if navigation.detailLayer != nil {
            let isSelected = navigation.isShowingInDetailLayer(page)
            label()
                .palette(isSelected ? palette.selectedPost : palette)
                .environment(\.unselectedPostPalette, isSelected ? palette : nil)
                .contentShape(.rect)
                .onTapGesture { navigation.push(page) }
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        } else {
            NavigationLink(page, label: label)
        }
    }
}
