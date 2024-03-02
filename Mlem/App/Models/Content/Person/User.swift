//
//  MyUser.swift
//  Mlem
//
//  Created by Sjmarf on 13/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class User: Person3Providing, UserProviding {
    var source: ApiClient
    
    static let identifierPrefix: String = "@"
    typealias ApiType = ApiGetSiteResponse
    
    let stub: UserStub
    let person3: Person3
    
    let instance: Instance3
  
    init(source: ApiClient, stub: UserStub, person3: Person3, instance: Instance3) {
        self.source = source
        self.stub = stub
        self.person3 = person3
        self.instance = instance
    }
    
    var id: Int { person3.id }
    
    var name: String { stub.name }
}
