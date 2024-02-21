//
//  ErrorDetails+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 31/08/2023.
//

import Foundation

private enum MockError: Error {
    case mock
}

extension ErrorDetails {
    static func mock(
        title: String? = nil,
        body: String? = nil,
        error: Error? = MockError.mock,
        icon: String? = nil,
        buttonText: String? = nil,
        refresh: (() async -> Bool)? = {
            try? await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
            return false
        },
        autoRefresh: Bool = false
    ) -> ErrorDetails {
        .init(
            title: title,
            body: body,
            error: error,
            icon: icon,
            buttonText: buttonText,
            refresh: refresh,
            autoRefresh: autoRefresh
        )
    }
}
