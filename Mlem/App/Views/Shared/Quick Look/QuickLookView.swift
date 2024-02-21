//
//  QuickLookView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-07.
//

import Foundation
import SwiftUI

/// Wraps UIKit's `QLPreviewController` for use in SwiftUI.
/// This view exists to workaround issue where SwiftUI's Quick Look view doesn't work with interactive dismissal gesture. [2023.08]
struct QuickLookView: UIViewControllerRepresentable {
    /// File paths to preview.
    let urls: [URL]
        
    func makeUIViewController(context: Context) -> QuickLookPreviewController {
        .init(urls: urls)
    }
    
    func updateUIViewController(_ uiViewController: QuickLookPreviewController, context: Context) {
        // no-op.
    }
}
