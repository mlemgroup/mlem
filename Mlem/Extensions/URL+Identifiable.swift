//
//  URL+Identifiable.swift
//  Mlem
//
//  Created by Nicholas Lawson on 04/06/2023.
//

import Foundation

extension URL: Identifiable {
    public var id: URL { absoluteURL }

    var isImage: Bool {
        pathExtension.lowercased().contains(["jpg", "jpeg", "png", "webp", "gif", "mp4"])
    }
}
