//
//  Save.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

import Foundation

struct SaveButton: View {
    let saved: Bool
    
    var body: some View {
        Image(systemName: "bookmark.fill")
            .if (saved) { viewProxy in
                viewProxy
                    .padding(4)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 4)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(.saveColor))
            }
            .if (!saved) { viewProxy in
                viewProxy
                    .padding(4)
                    .foregroundColor(.secondary)
                    // .foregroundColor(.primary)
            }
    }
}
