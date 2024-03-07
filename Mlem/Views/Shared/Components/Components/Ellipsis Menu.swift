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
    
    @State private var menuFunctionPopup: MenuFunctionPopup?

    var body: some View {
        Menu {
            ForEach(menuFunctions) { item in
                MenuButton(menuFunction: item, menuFunctionPopup: $menuFunctionPopup)
            }
        } label: {
            Image(systemName: Icons.menu)
                .frame(width: size, height: size)
                .foregroundColor(.primary)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(.clear))
        }
        .onTapGesture {} // allows menu to pop up on first tap
        .destructiveConfirmation(menuFunctionPopup: $menuFunctionPopup)
    }
}
