//
//  NavigationPath+Helpers.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-18.
//

import SwiftUI

extension NavigationPath {
    
    mutating func goBack(popToRoot: Bool = false) {
        guard !isEmpty else {
            return
        }
        let popDepth = popToRoot ? self.count : 1
        self.removeLast(popDepth)
    }
}
