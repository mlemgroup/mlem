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

                    if let dataFromString = demoPostResponse.data(using: .utf8, allowLossyConversion: false)
                    {
                        do
                        {
                            let parsedJSON: JSON = try JSON(data: dataFromString)

                            print("Parsed JSON: \(parsedJSON.debugDescription)")

                            let parsedDemoPosts = await parsePosts(postJSON: parsedJSON)

                            print("Parsed demo posts: \(parsedDemoPosts)")
                        }
                        catch let decodingError as NSError
                        {
                            print("Failed whil decoding JSON: \(decodingError)")
                        }
                    }
                }
        }
    }
}
