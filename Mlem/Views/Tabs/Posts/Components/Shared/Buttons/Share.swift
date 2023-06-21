//
//  Share.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct ShareButton: View {
    let size: CGFloat
    let shareFunc: () -> Void
    
    var body: some View {
        Image(systemName: "square.and.arrow.up")
            .frame(width: size, height: size)
            .foregroundColor(.primary)
            .background(RoundedRectangle(cornerRadius: 4)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(.clear))
            .onTapGesture {
                shareFunc()
            }
    }
}
