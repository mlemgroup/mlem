//
//  Image+Extensions.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-06.
//

import SwiftUI

public extension Image {
    init(_ icon: Icon) {
        let name = icon.computeImageName()
        switch icon.source {
        case .custom:
            self.init(name)
        case .system:
            self.init(systemName: name)
        }
    }
}
