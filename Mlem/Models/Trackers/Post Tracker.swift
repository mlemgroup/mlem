//
//  Post Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

class PostTracker: ObservableObject
{
    @Published var posts: [APIPostView] = .init()
    @Published var page: Int = 1
    @Published var isLoading: Bool = true
}
