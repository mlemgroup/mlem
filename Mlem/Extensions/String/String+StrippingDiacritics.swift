//
//  String+StrippingDiacritics.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-19.
//

import Foundation

extension StringProtocol {
    var strippingDiacritics: String {
        applyingTransform(.stripDiacritics, reverse: false)!
    }
}
