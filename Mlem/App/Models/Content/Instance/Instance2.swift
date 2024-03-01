//
//  Instance2.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class Instance2: Instance2Providing, ContentModel {
    typealias ApiType = ApiSiteView
    var instance2: Instance2 { self }
    var source: ApiClient
    
    let instance1: Instance1
    
    var cacheId: Int { instance1.cacheId }
    
    required init(source: ApiClient, from siteView: ApiSiteView) {
        self.source = source
        self.instance1 = .init(source: source, from: siteView.site)
    }

    func update(with siteView: ApiSiteView) {
        instance1.update(with: siteView.site)
    }
}
