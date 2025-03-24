//
//  ModlogItemFilter.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-28.
//

import Foundation

public enum ModlogEntryFilterType {}

class ModlogEntryFilter: MultiFilter<ModlogEntry> {
    override func allFilters() -> [any FilterProviding<ModlogEntry>] {
        []
    }
    
    override func getFilter(_ toGet: ModlogEntryFilterType) -> any FilterProviding<ModlogEntry> {}
}
