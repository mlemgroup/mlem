//
//  ReadFilter.swift
//
//
//  Created by Eric Andrews on 2024-05-31.
//

import Foundation

class ReadFilter<FilterTarget: ReadableProviding>: FilterProviding {
    var numFiltered: Int = 0
    var active: Bool = true
    
    func filter(_ targets: [FilterTarget]) -> [FilterTarget] {
        let ret = targets.filter { !$0.read }
        numFiltered += targets.count - ret.count
        return ret
    }
    
    func reset(with targets: [FilterTarget]?) -> [FilterTarget] {
        numFiltered = 0
        if let targets { return filter(targets) }
        return .init()
    }
}
