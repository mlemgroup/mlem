//
//  Comment Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftUI

class CommentTracker: ObservableObject
{
    @Published var comments: [Comment] = .init()
    @Published var isLoading: Bool = true
}
