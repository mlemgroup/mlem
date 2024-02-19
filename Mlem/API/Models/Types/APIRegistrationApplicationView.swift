//
//  APIRegistrationApplicationView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/RegistrationApplicationView.ts
struct APIRegistrationApplicationView: Codable {
    let registration_application: APIRegistrationApplication
    let creator_local_user: APILocalUser
    let creator: APIPerson
    let admin: APIPerson?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
