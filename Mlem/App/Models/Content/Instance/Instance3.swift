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
    
    var version: SiteVersion = .zero
    
    required init(source: ApiClient, from response: ApiGetSiteResponse) {
        self.source = source
        self.instance2 = .init(source: source, from: response.siteView)
        update(with: response)
    }

    func update(with response: ApiGetSiteResponse) {
        version = SiteVersion(response.version)
        instance2.update(with: response.siteView)
    }
}
