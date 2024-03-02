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
    var actorId: URL { source.actorId }
  
    init(source: ApiClient, instance1: Instance1) {
        self.source = source
        self.instance1 = instance1
    }

    func update(with siteView: ApiSiteView) {
        instance1.update(with: siteView.site)
    }
}
