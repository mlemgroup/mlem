//
//  APIRegistrationApplicationView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// RegistrationApplicationView.ts
struct APIRegistrationApplicationView: Decodable {
    let registrationApplication: APIRegistrationApplication
    let creatorLocalUser: APILocalUser
    let creator: APIPerson
    let admin: APIPerson?
}
