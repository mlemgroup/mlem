//
//  MyUser.swift
//  Mlem
//
//  Created by Sjmarf on 13/02/2024.
//

import Foundation
import SwiftUI

@Observable
class MyUser: MyUserProviding, User3Providing {
    var source: any APISource { stub }
    var user2: User2 { user3.user2 }
    var user1: User1 { user3.user1 }
    
    let stub: MyUserStub
    let user3: User3
    
    init(stub: MyUserStub, user3: User3) {
        self.stub = stub
        self.user3 = user3
    }
}
