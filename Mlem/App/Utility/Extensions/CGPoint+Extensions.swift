//
//  CGPoint+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 16/08/2024.
//

import Foundation

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(pow(point.x - x, 2) + pow(point.y - y, 2))
    }
}
