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
    
    var columns: [GridItem] {
        switch self {
        case .compact, .headline, .large: [GridItem(.flexible(), spacing: 0)]
        case .tile: [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
        }
    }
}
