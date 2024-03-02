//
//  Instance3.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class Instance3: Instance3Providing, ContentModel, CacheIdentifiable {
    typealias ApiType = ApiGetSiteResponse
    var instance3: Instance3 { self }
    var source: ApiClient
    
    let instance2: Instance2
    
    var cacheId: Int { instance2.cacheId }
    var actorId: URL { source.actorId }
    
    var version: SiteVersion
  
    init(source: ApiClient, instance2: Instance2, version: SiteVersion) {
        self.source = source
        self.instance2 = instance2
        self.version = version
    }

    func update(with response: ApiGetSiteResponse) {
        version = SiteVersion(response.version)
        instance2.update(with: response.siteView)
    }
}
