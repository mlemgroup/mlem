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
    
    init(source: UserStub, from response: ApiGetSiteResponse) {
        self.stub = source
        
        guard let myUser = response.myUser else { fatalError() }
        
        if let existing = source.caches.person3.retrieveModel(id: myUser.localUserView.localUser.id) {
            self.person3 = existing
            existing.update(with: myUser)
        } else {
            self.person3 = .init(source: source.api, from: response)
        }
        
        self.instance = .create(from: response)
        self.source = source.api
    }
    
    var id: Int { person3.id }
    
    var name: String { stub.name }
}
