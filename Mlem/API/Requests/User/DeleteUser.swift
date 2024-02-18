//
//  DeleteUser.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-11
//

import Foundation

// TODO: 0.18 deprecation remove this struct
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
        account: UserStub,
        password: String
    ) {
        self.instanceURL = account.instance.url
        self.body = .init(
            password: password,
            auth: account.accessToken
        )
    }
}

struct DeleteAccountRequest: APIPostRequest {
    typealias Response = SuccessResponse
    
    let instanceURL: URL
    let path = "user/delete_account"
    let body: Body
    
    // lemmy_api_common::person::DeleteAccount
    struct Body: Encodable {
        let password: String
        let delete_content: Bool
    }
    
    init(
        account: UserStub,
        password: String,
        deleteContent: Bool
    ) {
        self.instanceURL = account.instance.url
        self.body = .init(
            password: password,
            delete_content: deleteContent
        )
    }
}

struct DeleteAccountResponse: Decodable {}
