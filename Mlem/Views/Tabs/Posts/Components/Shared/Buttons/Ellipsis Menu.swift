//
//  Ellipsis Menu.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-19.
//

import SwiftUI

struct EllipsisMenu: View {
    let size: CGFloat
    let shareUrl: String
    
    var body: some View {
        Menu {
            if let url = URL(string: shareUrl) {
                Button("Share") { showShareSheet(URLtoShare: url) }
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
