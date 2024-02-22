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
        pathExtension.lowercased().contains(["jpg", "jpeg", "png", "webp"])
    }
}

extension URL {
    // Spec described here: https://join-lemmy.org/docs/contributors/04-api.html#images
    func withIconSize(_ size: Int) -> URL {
        var result = self
        result.append(queryItems: [URLQueryItem(name: "thumbnail", value: "\(size)")])
        return result
    }
}
