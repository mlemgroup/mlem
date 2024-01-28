//
//  UserContentModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation

enum UserContentModel {
    case post(PostModel)
    case comment(HierarchicalComment)
}
