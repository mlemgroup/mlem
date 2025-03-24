//
//  ImageUpload1Backer.swift
//
//
//  Created by Sjmarf on 26/08/2024.
//

import Foundation

public protocol ImageUpload1Backer: CacheIdentifiable {
    var alias: String { get }
    var deleteToken: String { get }
}
