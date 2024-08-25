//
//  Bundle+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 25/08/2024.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}
