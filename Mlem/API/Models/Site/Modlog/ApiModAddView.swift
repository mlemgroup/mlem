//
//  ApiModAddView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModAddView.ts
struct ApiModAddView: Decodable {
    let modAdd: ApiModAdd
    let moderator: APIPerson?
    let moddedPerson: APIPerson
}
