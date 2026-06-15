//
//  PersonSortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation

public extension PersonSortType {
    static func `default`(software: SiteSoftware) -> Self {
        if software.supports(.personSortType(.postCount)) {
            .postCount
        } else if software.supports(.personSortType(.commentCount)) {
            .commentCount
        } else {
            .postScore
        }
    }
}
