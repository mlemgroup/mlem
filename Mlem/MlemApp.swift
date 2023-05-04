//
//  MlemApp.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI
import SwiftyJSON

@main
struct MlemApp: App
{
    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .task(priority: .background)
                {
                    let demoPostResponse: String = AppConstants.demoPostResponse

                    let parsedPosts = try! await parsePosts(postResponse: demoPostResponse)
                    
                    print("A debug result: \(String(describing: parsedPosts.randomElement()?.embedHTML))")
                    
                    let commandResult: String = try! await sendCommand(maintainOpenConnection: false, instanceAddress: "hexbear.net", command: """
        {"op": "GetPosts", "data": {"type_": "All", "sort":"Hot", "page": \(1)}}
        """)
                    print("Command result: \(commandResult)")
                }
        }
    }
}
