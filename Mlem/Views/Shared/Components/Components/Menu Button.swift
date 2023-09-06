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
    
//    @Binding private var isPresentingConfirmDelete: Bool = false
//    @Binding private var confirmationMenuFunction: StandardMenuFunction?

    var body: some View {
        switch menuFunction {
        case let .share(shareMenuFunction):
            ShareLink(item: shareMenuFunction.url)
        case let .standard(standardMenuFunction):
            let role: ButtonRole? = standardMenuFunction.destructiveActionPrompt != nil ? .destructive : nil
            Button(role: role) {
                if standardMenuFunction.destructiveActionPrompt != nil, let confirmDestructive {
                    confirmDestructive(standardMenuFunction)
                } else {
                    standardMenuFunction.callback()
                }
//                if standardMenuFunction.destructiveActionPrompt != nil {
//                    print("confirming delete...")
//                    confirmationMenuFunction = standardMenuFunction
//                    isPresentingConfirmDelete = true
//                } else {
//                    standardMenuFunction.callback()
//                }
            } label: {
                Label(standardMenuFunction.text, systemImage: standardMenuFunction.imageName)
            }
            .disabled(!standardMenuFunction.enabled)
        }
    }
}
