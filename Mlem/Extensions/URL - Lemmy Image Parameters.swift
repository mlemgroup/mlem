//
//  URL - Lemmy Image Parameters.swift
//  Mlem
//
//  Created by Jake Shirley on 7/6/23.
//

import Foundation

extension URL {
    // Returns a "small" version of the icon
    // Spec described here: https://join-lemmy.org/docs/contributors/04-api.html#images
    var withIcon32Parameters: URL {
        var result = self
        result.append(queryItems: [URLQueryItem(name: "thumbnail", value: "32")])
        return result
    }
    
    var withIcon64Parameters: URL {
        var result = self
        result.append(queryItems: [URLQueryItem(name: "thumbnail", value: "64")])
        return result
    }
}
