//
//  Instance3Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol Instance3Providing: Instance2Providing {
    var instance3: Instance3 { get }
    
    var version: SiteVersion { get }
}

extension Instance3Providing {
    var instance2: Instance2 { instance3.instance2 }
    
    var version: SiteVersion { instance3.version }
    
    var version_: SiteVersion { instance3.version }
}
