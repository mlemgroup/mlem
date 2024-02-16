//
//  BanUser.swift
//  Mlem
//
//  Created by Sjmarf on 26/01/2024.
//

import Dependencies
import Foundation
import SwiftUI

struct BanUserEditorModel: Identifiable {
    @Dependency(\.commentRepository) var commentRepository
    
    let user: UserModel
    var callback: (_ item: UserModel) -> Void = { _ in }
    var id: Int { user.userId }
}
