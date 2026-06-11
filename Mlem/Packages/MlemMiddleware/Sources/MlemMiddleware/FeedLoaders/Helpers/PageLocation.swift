//
//  PageLocation.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-11.
//

enum PageLocation: Hashable {
    case at(PageCursor)
    case end

    static var start: PageLocation { .at(.first) }

    var cursor: PageCursor? {
        switch self {
        case let .at(cursor): cursor
        case .end: nil
        }
    }
}

extension PageLocation: CustomStringConvertible {
    var description: String {
        switch self {
        case let .at(cursor): "PageLocation(\(cursor.innerDescription))"
        case .end: "PageLocation(END)"
        }
    }
}
