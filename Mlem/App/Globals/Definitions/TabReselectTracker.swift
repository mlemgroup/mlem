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
    var flag: Bool = false
    
    static var main: TabReselectTracker = .init()
    
    func signal() {
        flag = !flag
    }
}
