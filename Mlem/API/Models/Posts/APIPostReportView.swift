//
//  APIPostReportView.swift
//  Mlem
//
//  Created by Jake Shirley on 7/1/23.
//
import Foundation

// lemmy_db_views::structs::PostReportView
struct APIPostReportView: Decodable {
    let postReport: APIPostReport
    let post: APIPost
    let community: APICommunity
    let creator: APIPerson
    let postCreator: APIPerson
    let creatorBannedFromCommunity: Bool
    let myVote: Int?
    let counts: APIPostAggregates
    let resolver: APIPerson?
}
