//
//  Comment Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

class CommentTracker: ObservableObject {
    @Published var comments: [HierarchicalComment] = .init()
    @Published var isLoading: Bool = true
    
    private var ids: Set<Int> = .init()
    
    /// A method to add new comments into the tracker, duplicate comments will be rejected
    func add(_ newComments: [HierarchicalComment]) {
        let accepted = newComments.filter { ids.insert($0.id).inserted }
        comments.append(contentsOf: accepted)
    }
}
