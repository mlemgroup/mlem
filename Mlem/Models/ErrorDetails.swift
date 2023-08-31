//
//  ErrorDetails.swift
//  Mlem
//
//  Created by Sjmarf on 31/08/2023.
//

import SwiftUI
import UniformTypeIdentifiers
import Combine

struct ErrorDetails {
    var title: String?
    var body: String?
    var error: Error?
    var icon: String?
    var buttonText: String?
    var refresh: (() async -> Bool)?
    var autoRefresh: Bool = false
}
