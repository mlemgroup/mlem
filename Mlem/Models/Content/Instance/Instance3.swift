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
    typealias ApiType = ApiGetSiteResponse
    var instance3: Instance3 { self }
    
    let instance2: Instance2
    
    var version: SiteVersion = .zero
    
    required init(from response: ApiGetSiteResponse) {
        self.instance2 = .create(from: response.siteView)
        update(with: response)
    }

    func update(with response: ApiGetSiteResponse) {
        version = SiteVersion(response.version)
        instance2.update(with: response.siteView)
    }
}
