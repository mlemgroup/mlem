//
//  Instance3.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class Instance3: Instance3Providing {
    var api: ApiClient
    var instance3: Instance3 { self }
    
    let instance2: Instance2
    
    var version: SiteVersion
  
    init(api: ApiClient, instance2: Instance2, version: SiteVersion) {
        self.api = api
        self.instance2 = instance2
        self.version = version
    }
}
