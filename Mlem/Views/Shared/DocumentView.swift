//
//  DocumentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//

import Foundation
import SwiftUI

/// Displays a document
struct DocumentView: View {
    
    @Environment(\.dismiss) private var dismiss
    let text: String
    
    var body: some View {
        ScrollView {
            MarkdownView(text: text, isNsfw: false)
                .padding()
        }
        .fancyTabScrollCompatible()
        .hoistNavigation(dismiss: dismiss)
    }
}
