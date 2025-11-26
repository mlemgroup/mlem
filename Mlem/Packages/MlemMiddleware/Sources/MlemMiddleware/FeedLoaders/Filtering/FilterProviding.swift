//
//  FilterProviding.swift
//
//
//  Created by Eric Andrews on 2024-05-31.
//

import Foundation

class FilterProviding<FilterTarget> {
    var context: FilterContext
    
    /// How many items this filter has caught
    var numFiltered: Int = 0
    var active: Bool = true
    
    init(context: FilterContext) {
        self.context = context
    }
    
    /// Given a list of `FilterTarget`s, returns all members that pass the filter and tracks how many members do not
    /// - Parameter targets: list of `FilterTarget`s to filter
    func filter(_ targets: [FilterTarget]) -> [FilterTarget] {
        let ret = targets.filter(shouldPassFilter)
        numFiltered += targets.count - ret.count
        return ret
    }
    
    /// Clears the filter and processes all provided targets
    /// - Parameter targets: optional list of `FilterTarget`s; if present, these will be filtered and the results returned
    func reset(with targets: [FilterTarget]?) -> [FilterTarget] {
        numFiltered = 0
        if let targets { return filter(targets) }
        return .init()
    }
    
    /// Returns true if the given post should pass the filter, false otherwise
    public func shouldPassFilter(_ item: FilterTarget) -> Bool {
        preconditionFailure("This method must be implemented by the inheriting class")
    }
    
    
    func updateFilterContext(to context: FilterContext) {
        self.context = context
    }
}
