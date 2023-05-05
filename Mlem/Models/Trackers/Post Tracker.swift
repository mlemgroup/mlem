//
//  Post Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI

class PostTracker: ObservableObject
{
    @Published var posts: [Post] = .init()
    @Published var page: Int = 1
    @Published var isLoading: Bool = true
}
