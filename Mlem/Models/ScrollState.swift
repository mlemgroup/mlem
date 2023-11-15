//
//  ScrollState.swift
//  Mlem
//
//  Created by Sumeet Gill on 2023-11-15.
//

import Foundation

class ScrollState: ObservableObject {
    var shouldScrollToTop: Bool = false
    var clickCount: Int = 0
}
