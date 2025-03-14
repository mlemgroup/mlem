//
//  CGSize+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-24.
//

import Foundation

extension CGSize {
    var aspectRatio: Double {
        height / width
    }
}
