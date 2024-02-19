//
//  APIPersonViewLike.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

protocol APIPersonViewLike {
    var person: APIPerson { get }
    var counts: APIPersonAggregates { get }
}
