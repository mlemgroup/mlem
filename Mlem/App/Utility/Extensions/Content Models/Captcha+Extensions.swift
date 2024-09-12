//
//  Captcha+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 06/09/2024.
//

import MlemMiddleware
import SwiftUI

extension Captcha {
    var uiImage: UIImage? {
        .init(data: imageData)
    }
    
    var image: Image? {
        if let uiImage {
            .init(uiImage: uiImage)
        } else {
            nil
        }
    }
}
