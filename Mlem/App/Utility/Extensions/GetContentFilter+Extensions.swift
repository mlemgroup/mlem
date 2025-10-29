//
//  GetContentFilter+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-29.
//  

import Foundation
import MlemMiddleware

extension GetContentFilter {
    var label: LocalizedStringResource {
        switch self {
        case .saved: "Saved"
        case .upvoted: "Upvoted"
        case .downvoted: "Downvoted"
        }
    }
}
