//
//  MultiFilter.swift
//
//
//  Created by Eric Andrews on 2024-06-03.
//

import Foundation

class MultiFilter<FilterTarget: Filterable> {
    var numFiltered: Int { allFilters().reduce(0) { $0 + $1.numFiltered } }
    
    /// Lists all filters in this MultiFilter. Used internally to iterate over filters and perform filtering logic. This function bridges the gap between the generic behavior, which wants a list of `[any FilterProviding<FilterTarget>]` to use in filtering, and the instantiating class, which is far more ergonomic if filters can be declared as simple member variables.
    /// - Returns: list of all filters in this MultiFilter
    func allFilters() -> [any FilterProviding<FilterTarget>] { [] }
    
    /// Gets a particular optional filter. Used internally to back the `activate`, `deactivate`, and `filteredCount` methods; as with `allFilters`, used to bridge generic and concrete behavior.
    /// - Parameter toGet: `OptionalFilters` describing the filter to get
    /// - Returns: filter corresponding to `toGet`
    func getFilter(_ toGet: FilterTarget.FilterType) -> any FilterProviding<FilterTarget> {
        preconditionFailure("This method must be implemented by the instantiating class")
    }
    
    func filter(_ targets: [FilterTarget]) -> [FilterTarget] {
        var ret: [FilterTarget] = targets
        for filter in allFilters() where filter.active {
            ret = filter.filter(ret)
        }
        return ret
    }
    
    /// Resets this filter and all its children
    /// - Parameter targets optional; if present, will immediately re-filter all targets
    /// - Returns result of filtering targets, if present, otherwise an empty array
    @discardableResult
    func reset(with targets: [FilterTarget] = .init()) -> [FilterTarget] {
        var ret = targets
        for filter in allFilters() {
            if filter.active {
                ret = filter.reset(with: ret)
            } else {
                _ = filter.reset(with: nil)
            }
        }
        return ret
    }
    
    /// Activates the given filter
    /// - Parameter filter: filter to activate
    /// - Returns: true if the filter was successfully activated, false if it was already active
    func activate(_ toActivate: FilterTarget.FilterType) -> Bool {
        var filter = getFilter(toActivate)
        let ret = !filter.active
        filter.active = true
        return ret
    }
    
    /// Deactivates the given filter
    /// - Parameter filter: filter to deactivate
    /// - Returns: true if the filter was successfully deactivated, false if it was already inactive
    func deactivate(_ toDeactivate: FilterTarget.FilterType) -> Bool {
        var filter = getFilter(toDeactivate)
        let ret = filter.active
        filter.active = false
        return ret
    }
    
    func numFiltered(for filter: FilterTarget.FilterType) -> Int {
        getFilter(filter).numFiltered
    }
}
