//
//  QuickLookPaths.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-07.
//

import Foundation

/// Store file paths for previewing in Quick Look.
final class QuickLookPaths: ObservableObject {
    /// Path for file to preview.
    @Published var url: URL?
}
