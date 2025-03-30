//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation

#if DEBUG
    public extension Person2 {
        static func mock(
            person1: Person1,
            postCount: Int,
            commentCount: Int,
            isAdmin: Bool
        ) -> Person2 {
            Person2(
                api: person1.api,
                person1: person1,
                postCount: postCount,
                commentCount: commentCount,
                isAdmin: isAdmin
            )
        }
    }
#endif
