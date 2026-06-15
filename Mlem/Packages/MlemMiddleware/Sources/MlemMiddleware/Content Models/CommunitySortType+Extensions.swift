//
//  CommunitySortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation

public extension CommunitySortType {
    static func `default`(software: SiteSoftware) -> Self {
        if software.supports(.communitySortType(.subscriberCount)) {
            .subscriberCount
        } else {
            .postCount
        }
    }
}
