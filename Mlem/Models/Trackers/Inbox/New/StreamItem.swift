//
//  StreamItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-09.
//

import Foundation

/// Enum to package stream items from inbox sub-trackers
/// - present: indicates that an item is present and returns the item
/// - loading: indicates that an item is not present but more items are loading
/// - absent: indicates that no more items are present
enum StreamItem<T> {
    case present(T)
    case loading
    case absent
}
