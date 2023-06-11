//
//  Comment Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

class CommentTracker: ObservableObject
{
    @Published var comments: [HierarchicalComment] = .init()
    @Published var isLoading: Bool = true
}
