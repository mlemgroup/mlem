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
    var loadingParameters: [URLQueryItem] = []
    
    if let community
    {
        print("Will be in COMMUNITY scope")
        
        loadingParameters = [
            URLQueryItem(name: "type_", value: feedType.rawValue),
            URLQueryItem(name: "sort", value: sortingType.rawValue),
            URLQueryItem(name: "page", value: "\(postTracker.page)"),
            URLQueryItem(name: "community_id", value: "\(community.id)")
        ]
    }
    else
    {
        print("Will be in GLOBAL scope")
        
        loadingParameters = [
            URLQueryItem(name: "type_", value: feedType.rawValue),
            URLQueryItem(name: "sort", value: sortingType.rawValue),
            URLQueryItem(name: "page", value: "\(postTracker.page)"),
        ]
    }

    print("Page counter value: \(postTracker.page)")
    
    do
    {
        let apiResponse = try await sendGetCommand(account: account, endpoint: "post/list", parameters: loadingParameters)
        
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
        
        appState.alertType = .connectionToLemmyError
    }
}
