//
//  NavigationPath+Helpers.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-18.
//

import SwiftUI

extension NavigationPath {
    
    /// - Returns: Items count on navigation path after performing go back action.
    @discardableResult
    mutating func goBack(popToRoot: Bool = false) -> Int {
        guard !isEmpty else {
            return 0
        }
        let popDepth = popToRoot ? self.count : 1
        self.removeLast(popDepth)
        return self.count
    }
}
