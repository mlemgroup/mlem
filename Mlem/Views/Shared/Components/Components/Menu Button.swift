//
//  Menu Button.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-22.
//

import Foundation
import SwiftUI

struct MenuButton: View {
    let menuFunction: MenuFunction
    @Binding var menuFunctionPopup: MenuFunctionPopup?

    var body: some View {
        switch menuFunction {
        case .divider:
            Divider()
        case let .shareUrl(shareMenuFunction):
            ShareLink(item: shareMenuFunction.url)
        case let .shareImage(shareImageFunction):
            ShareLink(item: shareImageFunction.image, preview: .init("photo", image: shareImageFunction.image))
        case let .standard(standardMenuFunction):
            Button(role: standardMenuFunction.isDestructive ? .destructive : nil) {
                switch standardMenuFunction.role {
                case .standard(let callback):
                    callback()
                case .popup(let menuFunctionPopup):
                    self.menuFunctionPopup = menuFunctionPopup
                }
            } label: {
                Label(standardMenuFunction.text, systemImage: standardMenuFunction.imageName)
            }
            .disabled(!standardMenuFunction.enabled)
        case let .navigation(navigationMenuFunction):
            NavigationLink(navigationMenuFunction.destination) {
                Label(navigationMenuFunction.text, systemImage: navigationMenuFunction.imageName)
            }
        case let .group(groupMenuFunction):
            Menu {
                ForEach(groupMenuFunction.children) { child in
                    MenuButton(menuFunction: child, menuFunctionPopup: $menuFunctionPopup)
                }
            } label: {
                Label(groupMenuFunction.text, systemImage: groupMenuFunction.imageName)
            }
        }
    }
}
