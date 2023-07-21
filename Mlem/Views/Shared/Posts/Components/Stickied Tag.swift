//
//  Stickied Tag.swift
//  Mlem
//
//  Created by David Bureš on 04.04.2022.
//

import SwiftUI

enum StickiedTagType {
    case local
    case community
}

struct StickiedTag: View {
    let tagType: StickiedTagType
    let compact: Bool
    
    init(tagType: StickiedTagType = StickiedTagType.community, compact: Bool = false) {
        self.tagType = tagType
        self.compact = compact
    }

    var body: some View {
        HStack {
            Image(systemName: "pin.fill")
                .foregroundColor(calculateColor())
                .accessibilityLabel(tagType == .local ? "Post stickied to your local instance" : "Post stickied to your current community")
        }
        .font(compact ? .footnote : .subheadline)
        .foregroundColor(.mint)
    }
    
    private func calculateColor() -> Color {
        switch tagType {
        case .local:
            return .red
        case .community:
            return .green
        }
    }
}
