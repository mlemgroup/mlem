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
    
    // var role: ButtonRole? { menuFunction.destructiveActionPrompt != nil ? .destructive : nil }
    
    var body: some View {
        switch menuFunction {
        case let .share(shareMenuFunction):
            ShareLink(item: shareMenuFunction.url)
        case let .standard(standardMenuFunction):
            let role: ButtonRole? = standardMenuFunction.destructiveActionPrompt != nil ? .destructive : nil
            Button(role: role) {
                standardMenuFunction.callback()
            } label: {
                Label(standardMenuFunction.text, systemImage: standardMenuFunction.imageName)
            }
            .disabled(!standardMenuFunction.enabled)
        }
        
//        if let shareURL = menuFunction.shareURL {
//            ShareLink(item: shareURL)
//        } else {
//            Button(role: role) {
//                menuFunction.callback()
//            } label: {
//                Label(menuFunction.text, systemImage: menuFunction.imageName)
//            }
//            .disabled(!menuFunction.enabled)
//            .onAppear { print(menuFunction) }
//        }
    }
}
