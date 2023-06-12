//
//  Save.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

import Foundation

struct SaveButton: View {
    @State var saved: Bool
    
    var body: some View {
        Image(systemName: "bookmark")
            .if (saved) { viewProxy in
                viewProxy
                    .padding(4)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 2)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(.saveColor))
            }
            .if (!saved) { viewProxy in
                viewProxy
                    .padding(4)
                    .foregroundColor(.primary)
            }
    }
}
