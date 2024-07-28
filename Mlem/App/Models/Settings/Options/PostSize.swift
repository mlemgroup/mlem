//
//  PostSize.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import SwiftUI

enum PostSize: String, CaseIterable {
    case compact, tile, headline, large
    
    var swipeBehavior: SwipeBehavior {
        switch self {
        case .compact, .headline, .large: .standard
        case .tile: .tile
        }
    }
}
