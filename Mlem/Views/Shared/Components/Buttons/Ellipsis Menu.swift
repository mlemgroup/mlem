//
//  Ellipsis Menu.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-19.
//

import SwiftUI

struct EllipsisMenu: View {
    let size: CGFloat
    let menuFunctions: [MenuFunction]
    
    // bindings
    @State private var isPresentingConfirmDelete: Bool = false
    @State private var confirmationMenuFunction: MenuFunction?
    
    var body: some View {
        Menu {
            ForEach(menuFunctions) { item in
                Button(role: item.destructiveActionPrompt != nil ? .destructive : nil) {
                    
                    // If we have destructive prompt, set this state to let the prompt
                    // show and let the user action
                    if item.destructiveActionPrompt != nil {
                        confirmationMenuFunction = item
                        isPresentingConfirmDelete = true
                    } else {
                        item.callback()
                    }
                } label: {
                    Label(item.text, systemImage: item.imageName)
                }.disabled(!item.enabled)
            }
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: size, height: size)
                .foregroundColor(.primary)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(.clear))
        }
        .onTapGesture { } // allows menu to pop up on first tap
        .confirmationDialog("Destructive Action Confirmation", isPresented: $isPresentingConfirmDelete) {
            if let destructiveCallback = confirmationMenuFunction?.callback {
                Button("Yes", role: .destructive) {
                    Task {
                        destructiveCallback()
                    }
                }
            }
        } message: {
            if let destructivePrompt = confirmationMenuFunction?.destructiveActionPrompt {
                Text(destructivePrompt)
            }
        }
    }
}
