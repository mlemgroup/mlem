//
//  Post2.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import SwiftUI

@Observable
final class Post2: Post2Providing, NewContentModel {
    typealias APIType = APIPostView
    var post2: Post2 { self }
    
    let post1: Post1
}
