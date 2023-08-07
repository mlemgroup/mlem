//
//  Double.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-07.
//

import Foundation

// MARK: - SwiftUI
extension Double {
    
    /// Use this value in SwiftUI to modify a view to be the top-most layer.
    ///
    /// This sentinel value exists because using `Int.max` doesn't work.
    static var maxZIndex: Double {
        /// [2023.08] `Int.max` doesn't work, which is why this is set to just some big value.
        return 99999
    }
}
