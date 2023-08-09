//
//  APIContentViewProtocol.swift
//  Mlem
//
//  Created by Sam Marfleet on 09/08/2023.
//

import Foundation

protocol APIContentViewProtocol {
    associatedtype AggregatesType: APIContentAggregatesProtocol
    
    var post: APIPost { get }
    var creator: APIPerson { get }
    var community: APICommunity { get }
    var counts: AggregatesType { get }
    var saved: Bool { get }
    var myVote: ScoringOperation? { get set }
    var creatorBlocked: Bool { get }
    var subscribed: APISubscribedStatus { get }
    var creatorBannedFromCommunity: Bool { get }
}
