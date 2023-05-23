//
//  Infinite loader.swift
//  Mlem
//
//  Created by David Bureš on 18.06.2022.
//

import Foundation
import SwiftUI

internal enum LoadingError
{
    case shittyInternet
}

func loadInfiniteFeed(postTracker: PostTracker, appState: AppState, instanceAddress: URL, community: Community?, sortingType: SortingOptions, account: SavedAccount) async
{
    var loadingCommand: String = ""
    
    if let community
    {
        print("Will be in COMMUNITY scope")
        
        loadingCommand = """
        {"op": "GetPosts", "data": {"auth": "\(account.accessToken)", "type_": "All", "sort": "\(sortingType.rawValue)", "page": \(postTracker.page), "community_id": \(community.id)}}
        """
    }
    else
    {
        print("Will be in GLOBAL scope")
        
        loadingCommand = """
        {"op": "GetPosts", "data": {"auth": "\(account.accessToken)", "type_": "All", "sort": "\(sortingType.rawValue)", "page": \(postTracker.page)}}
        """
    }

    print("Page counter value: \(postTracker.page)")
    
    print("Will try to send command: \(loadingCommand)")
    
    do
    {
        let apiResponse = try await sendCommand(maintainOpenConnection: true, instanceAddress: instanceAddress, command: loadingCommand)
        
        print("API Response: \(apiResponse)")
        
        let parsedNewPosts: [Post] = try await parsePosts(postResponse: apiResponse, instanceLink: instanceAddress)
        
        DispatchQueue.main.async {
            for post in parsedNewPosts
            {
                postTracker.posts.append(post)
            }
            
            postTracker.page += 1
        }
    }
    catch let connectionError
    {
        print("Failed while loading feed: \(connectionError)")
        
        DispatchQueue.main.async {
            appState.criticalErrorType = .shittyInternet
            appState.isShowingCriticalError = true
        }
    }
}
