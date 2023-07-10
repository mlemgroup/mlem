//
//  OperationQueue - Easy init.swift
//  Mlem
//
//  Created by tht7 on 08/07/2023.
//

import Foundation

extension OperationQueue {
    convenience init(maxConcurrentCount: Int) {
        self.init()
        self.maxConcurrentOperationCount = maxConcurrentCount
    }
}
