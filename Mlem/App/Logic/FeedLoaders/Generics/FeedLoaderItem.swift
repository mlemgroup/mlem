//
//  FeedLoadable.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Foundation
import MlemMiddleware

protocol FeedLoadable: Equatable, AnyObject {
    var uid: ContentModelIdentifier { get }
    func sortVal(sortType: FeedLoaderSortType) -> FeedLoaderSortVal
    
    static func == (lhs: any FeedLoadable, rhs: any FeedLoadable) -> Bool
}

extension FeedLoadable {
    static func == (lhs: any FeedLoadable, rhs: any FeedLoadable) -> Bool {
        lhs.uid == rhs.uid
    }
}
