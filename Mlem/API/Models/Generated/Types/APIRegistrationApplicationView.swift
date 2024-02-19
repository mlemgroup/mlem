//
//  APIRegistrationApplicationView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/RegistrationApplicationView.ts
struct APIRegistrationApplicationView: Codable {
    let registrationApplication: APIRegistrationApplication
    let creatorLocalUser: APILocalUser
    let creator: APIPerson
    let admin: APIPerson?
}
