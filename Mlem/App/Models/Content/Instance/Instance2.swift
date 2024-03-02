//
//  Instance2.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class Instance2: Instance2Providing {
    var api: ApiClient
    var instance2: Instance2 { self }
    
    let instance1: Instance1

    init(api: ApiClient, instance1: Instance1) {
        self.api = api
        self.instance1 = instance1
    }
}
