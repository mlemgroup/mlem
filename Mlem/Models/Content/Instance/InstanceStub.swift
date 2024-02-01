//
//  InstanceStub.swift
//  Mlem
//
//  Created by Sjmarf on 22/01/2024.
//

import Foundation

struct InstanceStub: Codable {
    let name: String
    let host: String
    let avatar: String?
    let version: SiteVersion
    let userCount: Int
}
