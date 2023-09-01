//
//  ScrubberHint.swift
//  Mlem
//
//  Created by tht7 on 01/09/2023.
//

import SwiftUI

struct ScrubberHint: View {
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "arrow.left")
            Spacer()
            Text("""
Looking to scrub the video?
Try scrabbing in this label
""")
            .multilineTextAlignment(.center)
            Spacer()
            Image(systemName: "arrow.right")
        }
        .padding()
    }
}

#Preview {
    ScrubberHint()
}
