//
//  Get Community Details.swift
//  Mlem
//
//  Created by David Bureš on 09.05.2023.
//

import Foundation

func loadCommunityDetails(community: Community, instanceAddress: URL, account: SavedAccount) async throws -> CommunityDetails
{
    let response: String = try await sendCommand(maintainOpenConnection: false, instanceAddress: instanceAddress, command: """
    {"op": "GetCommunity", "data": {"auth": "\(account.accessToken)", "id": \(community.id)}}
    """)
    
    do
    {
        return try await parseCommunityDetails(response: response, instanceLink: instanceAddress)
    }
    catch let communityDetailsParsingError
    {
        print("Failed while parsing community details: \(communityDetailsParsingError)")
        throw JSONParsingError.failedToParse
    }
}
