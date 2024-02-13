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
    let confirmDestructive: ((StandardMenuFunction) -> Void)?

    var body: some View {
        switch menuFunction {
        case let .shareUrl(shareMenuFunction):
            ShareLink(item: shareMenuFunction.url)
        case let .shareImage(shareImageFunction):
            ShareLink(item: shareImageFunction.image, preview: .init("photo", image: shareImageFunction.image))
        case let .standard(standardMenuFunction):
            let role: ButtonRole? = standardMenuFunction.destructiveActionPrompt != nil ? .destructive : nil
            Button(role: role) {
                if standardMenuFunction.destructiveActionPrompt != nil, let confirmDestructive {
                    confirmDestructive(standardMenuFunction)
                } else {
                    standardMenuFunction.callback()
                }
            } label: {
                Label(standardMenuFunction.text, systemImage: standardMenuFunction.imageName)
            }
            .disabled(!standardMenuFunction.enabled)
        case let .navigation(navigationMenuFunction):
            NavigationLink(navigationMenuFunction.destination) {
                Label(navigationMenuFunction.text, systemImage: navigationMenuFunction.imageName)
            }
        case let .childMenu(titleKey, children):
            Menu(titleKey) {
                ForEach(children) { child in
                    MenuButton(menuFunction: child, confirmDestructive: nil)
                }
            }
        }
    }
}
