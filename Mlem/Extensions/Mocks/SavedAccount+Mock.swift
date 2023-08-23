//
//  SavedAccount+Mock.swift
//  Mlem
//
//  Created by mormaer on 20/08/2023.
//
//

import Foundation

extension SavedAccount {
    static func mock(
        id: Int = 0,
        instanceLink: URL = .mock,
        accessToken: String = "token",
        username: String = "username",
        storedNickname: String? = nil
    ) -> SavedAccount {
        .init(
            id: id,
            instanceLink: instanceLink,
            accessToken: accessToken,
            username: username,
            storedNickname: storedNickname
        )
    }
}
