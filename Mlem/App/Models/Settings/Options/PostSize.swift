//
//  PostSize.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import SwiftUI

enum PostSize: String, CaseIterable {
    case compact, headline, large
    
    var label: LocalizedStringResource {
        switch self {
        case .compact: "Compact"
        case .headline: "Headline"
        case .large: "Large"
        }
    }
}
