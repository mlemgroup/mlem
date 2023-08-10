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
    
    var role: ButtonRole? { menuFunction.destructiveActionPrompt != nil ? .destructive : nil }
    
    var body: some View {
        Button(role: role) {
            menuFunction.callback()
        } label: {
            Label(menuFunction.text, systemImage: menuFunction.imageName)
        }
        .disabled(!menuFunction.enabled)
    }
}
