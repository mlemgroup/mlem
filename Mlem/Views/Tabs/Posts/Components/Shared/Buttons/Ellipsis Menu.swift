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

    var body: some View {
        Menu {
            ForEach(menuFunctions) { item in
                Button {
                    item.callback()
                } label: {
                    Label(item.text, systemImage: item.imageName)
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: size, height: size)
                .foregroundColor(.primary)
                .background(RoundedRectangle(cornerRadius: 4)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(.clear))
        }
        .onTapGesture { } // allows menu to pop up on first tap
    }
}
