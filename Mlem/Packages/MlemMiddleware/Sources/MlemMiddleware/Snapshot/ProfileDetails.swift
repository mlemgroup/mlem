//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-07.
//

import Foundation

public struct ProfileDetails: Hashable, Sendable {
    public var avatar: URL?
    public var banner: URL?
    public var displayName: String?
    public var description: String?
    public var matrixUserId: String?
}

public struct ProfileDetailsMutation {
    let originalDetails: ProfileDetails
    let newDetails: ProfileDetails

    func isValid(forSoftware software: SiteSoftware) -> Bool {
        if originalDetails.displayName != newDetails.displayName, !software.supports(.editDisplayName) { return false }
        return true
    }
}
