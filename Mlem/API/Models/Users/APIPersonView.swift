//
//  APIPersonView.swift
//  Mlem
//
//  Created by Nicholas Lawson on 09/06/2023.
//

import Foundation

struct APIPersonView: Decodable {
    let counts: APIPersonAggregates
    let person: APIPerson
}
