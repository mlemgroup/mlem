//
//  ErrorDetails.swift
//  Mlem
//
//  Created by Sjmarf on 31/08/2023.
//

import Combine
import SwiftUI
import UniformTypeIdentifiers

struct ErrorDetails {
    var title: String?
    var body: String?
    var error: Error?
    var icon: String?
    var buttonText: String?
    var refresh: (() async -> Bool)?
    var autoRefresh: Bool = false
}
