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

func loadInfiniteFeed(postTracker: PostTracker, appState: AppState, community: Community?, feedType: FeedType, sortingType: SortingOptions, account: SavedAccount) async
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
        {"op": "GetPosts", "data": {"auth": "\(account.accessToken)", "type_": "\(feedType.rawValue)", "sort": "\(sortingType.rawValue)", "page": \(postTracker.page)}}
        """
    }

    print("Page counter value: \(postTracker.page)")
    
    print("Will try to send command: \(loadingCommand)")
    
    do
    {
        let apiResponse = try await sendGetCommand(account: account, endpoint: "/post/list", parameters: [
            URLQueryItem(name: "type_", value: feedType.rawValue),
            URLQueryItem(name: "sort", value: sortingType.rawValue),
            URLQueryItem(name: "page", value: "1")
        ])
        
        //let apiResponse = try await sendCommand(maintainOpenConnection: true, instanceAddress: account.instanceLink, command: loadingCommand)
        
        print("API Response: \(apiResponse)")
        
        if !apiResponse.contains("""
        "posts":[]}
        """)
        {
            let parsedNewPosts: [Post] = try await parsePosts(postResponse: apiResponse, instanceLink: account.instanceLink)
            
            DispatchQueue.main.async {
                for post in parsedNewPosts
                {
                    postTracker.posts.append(post)
                }
                
                postTracker.page += 1
            }
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
