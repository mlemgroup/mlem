//
//  ReadCheck.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-26.
//

import Icons
import SwiftUI
import Theming
import MlemMiddleware

struct ReadCheck: View {
    let dimension: CGFloat
    let read: ExpectedValue<Bool>
    
    init(read: ExpectedValue<Bool>, tiled: Bool = false) {
        self.read = read
        self.dimension = tiled ? 10 : 12
    }
    
    var body: some View {
        ExpectedView(read) { read in
            content(read: read)
        } placeholder: {
            ProgressView()
        }
    }
    
    @ViewBuilder
    func content(read: Bool) -> some View {
        if read {
            Image(icon: .general.success)
                .resizable()
                .scaledToFit()
                .frame(width: dimension, height: dimension)
                .foregroundStyle(.themedSecondary)
        }
    }
}
