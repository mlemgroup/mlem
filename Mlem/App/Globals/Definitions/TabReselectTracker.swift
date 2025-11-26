//
//  TabReselectTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-02.
//

import Foundation
import SwiftUI

@Observable
class TabReselectTracker {
    var blockTabSwitch: Bool = false
    private(set) var flag: Bool = false
    var consumers: Int = 0

    static var main: TabReselectTracker = .init()

    func signal() {
        flag = true
    }
    
    func reset() {
        flag = false
    }
}
