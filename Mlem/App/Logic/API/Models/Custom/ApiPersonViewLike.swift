//
//  ApiPersonViewLike.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

protocol ApiPersonViewLike {
    var person: ApiPerson { get }
    var counts: ApiPersonAggregates { get }
}
