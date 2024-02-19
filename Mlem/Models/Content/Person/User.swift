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
    static let identifierPrefix: String = "@"
    typealias APIType = APIGetSiteResponse
    
    let stub: UserStub
    let person3: Person3
    
    let instance: Instance3
    
    init(source: UserStub, from response: APIGetSiteResponse) {
        self.stub = source
        
        guard let myUser = response.myUser else { fatalError() }
        
        if let existing = source.caches.person3.retrieveModel(id: myUser.localUserView.localUser.id) {
            self.person3 = existing
            existing.update(with: myUser)
        } else {
            self.person3 = .init(source: source, from: response)
        }
        
        self.instance = .create(from: response)
    }
    
    var id: Int { person3.id }
    
    var name: String { stub.name }
}
