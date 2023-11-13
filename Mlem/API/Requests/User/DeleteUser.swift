//
//  DeleteUser.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-11
//

import Foundation

struct LegacyDeleteAccountRequest: APIPostRequest {
    typealias Response = DeleteAccountResponse

    let instanceURL: URL
    let path = "user/delete_account"
    let body: Body

    // lemmy_api_common::person::DeleteAccount
    struct Body: Encodable {
        let password: String
        let auth: String
    }

    init(
        account: SavedAccount,
        password: String
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            password: password,
            auth: account.accessToken
        )
    }
}

struct DeleteAccountRequest: APIPostRequest {
    typealias Response = DeleteAccountResponse
    
    let instanceURL: URL
    let path = "user/delete_account"
    let body: Body
    
    // lemmy_api_common::person::DeleteAccount
    struct Body: Encodable {
        let password: String
        let delete_content: Bool
    }
    
    init(
        account: SavedAccount,
        password: String,
        deleteContent: Bool
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            password: password,
            delete_content: deleteContent
        )
    }
}

struct DeleteAccountResponse: Decodable {}
