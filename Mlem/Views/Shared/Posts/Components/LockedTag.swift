//
//  LockedTag.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import SwiftUI

struct LockedTag: View {
    let compact: Bool
    
    var body: some View {
        Image(systemName: Icons.locked)
            .foregroundColor(.green)
            .font(compact ? .footnote : .subheadline)
            .accessibilityLabel("Post locked")
    }
}
