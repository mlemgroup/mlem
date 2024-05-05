//
//  Line.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import SwiftUI

// https://stackoverflow.com/a/63188568/17629371

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
