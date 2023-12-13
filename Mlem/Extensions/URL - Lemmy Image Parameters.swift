//
//  URL - Lemmy Image Parameters.swift
//  Mlem
//
//  Created by Jake Shirley on 7/6/23.
//

import Foundation

extension URL {
    // Spec described here: https://join-lemmy.org/docs/contributors/04-api.html#images
    func withIconSize(_ size: Int) -> URL {
        var result = self
        result.append(queryItems: [URLQueryItem(name: "thumbnail", value: "\(size)")])
        return result
    }
}

