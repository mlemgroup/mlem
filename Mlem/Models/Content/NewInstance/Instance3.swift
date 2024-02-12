//
//  Instance3.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class Instance3: Instance3Providing, CoreModel {
    static var cache: CoreContentCache<Instance3> = .init()
    typealias APIType = APISiteView
    var instance3: Instance3 { self }
    var instance1: Instance1 { self }
    
    let instance2: Instance2
    
    required init(from response: SiteResponse) {
        self.instance2 = .create(from: response.siteView)
    }

    func update(with response: SiteResponse) {
        self.instance2.update(with: response.siteView)
    }
}
