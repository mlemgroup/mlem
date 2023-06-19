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
    let size: CGFloat
    
    var body: some View {
        Image(systemName: "bookmark.fill")
            .frame(width: size, height: size)
            .foregroundColor(saved ? .white : .primary)
            .background(RoundedRectangle(cornerRadius: 4)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(saved ? .saveColor : .clear))
    }
}
