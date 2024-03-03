//
//  RemovedTag.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation
import SwiftUI

struct RemovedTag: View {
    let compact: Bool
    
    var body: some View {
        Image(systemName: Icons.removed)
            .foregroundColor(.red)
            .font(compact ? .footnote : .subheadline)
            .accessibilityLabel("Post removed by moderator")
    }
}
