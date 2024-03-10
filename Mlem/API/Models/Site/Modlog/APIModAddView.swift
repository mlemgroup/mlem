//
//  APIModAddView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModAddView.ts
struct APIModAddView: Decodable {
    let modAdd: APIModAdd
    let moderator: APIPerson?
    let moddedPerson: APIPerson
}
