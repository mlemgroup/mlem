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
    
    /// Returns the fist preferred localization according to `Bundle.main`, or at least, "en"
    static var preferredLocalization: String {
        guard let firstPreferredLocalization = Bundle.main.preferredLocalizations.first else {
            return "en"
        }
        return firstPreferredLocalization
    }
}
