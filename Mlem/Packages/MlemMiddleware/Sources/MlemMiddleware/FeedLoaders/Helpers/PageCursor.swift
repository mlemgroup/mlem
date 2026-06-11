//
//  PageCursor.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-11.
//

internal struct PageCursor: Hashable {
    internal enum CursorType: Hashable {
        case pageNumber(Int) // Starts at 1
        case cursorString(String)
    }

    internal enum PageCursorError: Error {
        case pageNumberRequired
        case pageCursorRequired
    }

    private let cursorType: CursorType

    internal init(cursorType: CursorType) {
        self.cursorType = cursorType
    }

    internal static var first: PageCursor {
        .init(cursorType: .pageNumber(1))
    }

    internal var pageNumber: Int? {
        switch cursorType {
        case let .pageNumber(value): value
        case .cursorString: nil
        }
    }

    internal var cursorString: String? {
        switch cursorType {
        case .pageNumber: nil
        case let .cursorString(value): value
        }
    }

    internal var requirePageNumber: Int {
        get throws(PageCursorError) {
            switch cursorType {
            case let .pageNumber(value):  value
            case .cursorString: throw .pageNumberRequired
            }
        }
    }

    internal var requireCursorString: String {
        get throws(PageCursorError) {
            switch cursorType {
            case .pageNumber: throw .pageCursorRequired
            case let .cursorString(value): value
            }
        }
    }

    internal func stepForward() throws(PageCursorError) -> PageCursor {
        .init(cursorType: .pageNumber(try self.requirePageNumber + 1))
    }
}

extension PageCursor: CustomStringConvertible {
    var innerDescription: String {
        switch self.cursorType {
        case let .cursorString(cursor): cursor
        case let .pageNumber(value): "page \(value)"
        }
    }

    var description: String {
        "PageCursor(\(innerDescription))"
    }
}
