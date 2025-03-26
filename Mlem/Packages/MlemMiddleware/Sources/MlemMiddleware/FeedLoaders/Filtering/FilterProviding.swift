//
//  FilterProviding.swift
//
//
//  Created by Eric Andrews on 2024-05-31.
//

import Foundation

protocol FilterProviding<FilterTarget> {
    associatedtype FilterTarget
    
    /// Given a list of `FilterTarget`s, returns all members that pass the filter and tracks how many members do not
    /// - Parameter targets: list of `FilterTarget`s to filter
    func filter(_ targets: [FilterTarget]) -> [FilterTarget]
    
    /// Clears the filter and processes all provided targets
    /// - Parameter targets: optional list of `FilterTarget`s; if present, these will be filtered and the results returned
    func reset(with targets: [FilterTarget]?) -> [FilterTarget]
    
    /// How many items this filter has caught
    var numFiltered: Int { get }
    
    var active: Bool { get set }
}
