//
//  Instance3Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol Instance3Providing: Instance2Providing {
    var instance3: Instance3 { get }
}

extension Instance3Providing {
    var instance2: Instance2 { instance3.instance2 }
}
