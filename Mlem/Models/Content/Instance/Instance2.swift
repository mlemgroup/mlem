//
//  Instance2.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class Instance2: Instance2Providing, CoreModel {
    static var cache: CoreContentCache<Instance2> = .init()
    typealias ApiType = ApiSiteView
    var instance2: Instance2 { self }
    
    let instance1: Instance1
    
    required init(from siteView: ApiSiteView) {
        self.instance1 = .create(from: siteView.site)
    }

    func update(with siteView: ApiSiteView) {
        instance1.update(with: siteView.site)
    }
}
