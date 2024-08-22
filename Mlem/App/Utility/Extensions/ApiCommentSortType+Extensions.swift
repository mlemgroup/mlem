//
//  ApiCommentSortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 21/08/2024.
//

import Foundation
import MlemMiddleware

extension ApiCommentSortType {
    static let allCases: [Self] = [.hot, .top, .new, .old, .controversial]
    
    var minimumVersion: SiteVersion {
        switch self {
        case .controversial: .v19_0
        default: .zero
        }
    }
    
    var label: LocalizedStringResource {
        switch self {
        case .hot: "Hot"
        case .top: "Top"
        case .new: "New"
        case .old: "Old"
        case .controversial: "Controversial"
        }
    }
    
    var systemImage: String {
        switch self {
        case .hot: Icons.hotSort
        case .top: Icons.topSort
        case .new: Icons.newSort
        case .old: Icons.oldSort
        case .controversial: Icons.controversialSort
        }
    }
}
