//
//  PostKeywordFilter.swift
//
//
//  Created by Eric Andrews on 2024-06-02.
//

import Foundation

class PostKeywordFilter: FilterProviding {
    typealias FilterTarget = Post2
    
    var numFiltered: Int = 0
    private var context: FilterContext
    var active: Bool = true
    
    init(context: FilterContext) {
        self.context = context
    }
    
    func filter(_ targets: [Post2]) -> [Post2] {
        let ret = targets.filter(shouldPassFilter)
        numFiltered += targets.count - ret.count
        return ret
    }
    
    func reset(with targets: [Post2]?) -> [Post2] {
        numFiltered = 0
        if let targets { return filter(targets) }
        return .init()
    }
    
    /// Returns true if the given post should pass the filter, false otherwise
    public func shouldPassFilter(_ post: Post2) -> Bool {
        // bypass filter for moderated/administrated posts
        if context.isAdmin || context.moderatedCommunityActorIds.contains(post.community.actorId) { return true }
        
        return !post.title.failsKeywordFilter(context.filteredKeywords)
    }
    
    func updateFilterContext(to context: FilterContext) {
        self.context = context
    }
}
