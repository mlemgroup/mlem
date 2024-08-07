//
//  Settings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-07.
//  Adapted from https://www.avanderlee.com/swift/appstorage-explained/
//

import Foundation
import SwiftUI

// This has to be ObservableObject because Observed currently does not allow @AppStorage properties without @ObservationIgnored
class Settings: ObservableObject {
    public static let main: Settings = .init()
    
    @AppStorage("post.size") var postSize: PostSize = .compact
}
