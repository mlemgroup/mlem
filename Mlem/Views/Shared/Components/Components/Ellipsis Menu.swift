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
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    var body: some View {
        Menu {
            ForEach(menuFunctions) { menuFunction in
                MenuButton(menuFunction: menuFunction, confirmDestructive: confirmDestructive)
            }
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: size, height: size)
                .foregroundColor(.primary)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(.clear))
        }
        .onTapGesture {} // allows menu to pop up on first tap
        .destructiveConfirmation(
            isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
            confirmationMenuFunction: confirmationMenuFunction
        )
    }
}
