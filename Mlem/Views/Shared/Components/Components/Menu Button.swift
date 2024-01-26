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
            let role: ButtonRole? = standardMenuFunction.role != nil ? .destructive : nil
            Button(role: role) {
                if case let .destructive(prompt: prompt) = standardMenuFunction.role, prompt != nil, let confirmDestructive {
                    confirmDestructive(standardMenuFunction)
                } else {
                    standardMenuFunction.callback()
                }
            } label: {
                Label(standardMenuFunction.text, systemImage: standardMenuFunction.imageName)
            }
            .disabled(!standardMenuFunction.enabled)
        }
    }
}
