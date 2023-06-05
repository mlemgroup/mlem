//
//  Get Community Details.swift
//  Mlem
//
//  Created by David Bureš on 09.05.2023.
//

import Foundation

func loadCommunityDetails(community: Community, account: SavedAccount, appState: AppState) async throws -> CommunityDetails
{
    
    do
    {
        let response: String = try await sendGetCommand(appState: appState, account: account, endpoint: "community", parameters: [
            URLQueryItem(name: "id", value: "\(community.id)")
        ])
        
        print("Community details response: \(response)")
        
        do
        {
            return try await parseCommunityDetails(response: response, instanceLink: account.instanceLink)
        }
        catch let communityDetailsParsingError
        {
            print("Failed while parsing community details: \(communityDetailsParsingError)")
            throw JSONParsingError.failedToParse
        }
    }
    catch let communityDetailsRetrievalError
    {
        print("Failed while getting community details: \(communityDetailsRetrievalError)")
        throw ConnectionError.failedToSendRequest
    }
}
