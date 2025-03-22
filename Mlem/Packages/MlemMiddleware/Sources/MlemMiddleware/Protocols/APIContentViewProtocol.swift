//
//  ApiContentViewProtocol.swift
//  Mlem
//
//  Created by Sjmarf on 09/08/2023.
//

import Foundation

protocol ApiContentViewProtocol {
    associatedtype AggregatesType: ApiContentAggregatesProtocol
    
    var post: ApiPost { get }
    var creator: ApiPerson { get }
    var community: ApiCommunity { get }
    var counts: AggregatesType { get }
    var saved: Bool { get }
    var myVote: ScoringOperation? { get set }
}
