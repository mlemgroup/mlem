//
//  CGSize+Extensions.swift
//  Media
//
//  Created by Eric Andrews on 2025-04-20.
//

import Foundation

extension CGSize {
    var aspectRatio: Double {
        height / width
    }
}
