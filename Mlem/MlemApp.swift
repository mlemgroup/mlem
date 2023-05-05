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
    @StateObject var appState: AppState = .init()
    @StateObject var communitiesTracker: SavedCommunityTracker = .init()

    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .environmentObject(appState)
                .environmentObject(communitiesTracker)
                .onChange(of: communitiesTracker.savedCommunities)
                { newValue in
                    do
                    {
                        let encodedSavedCommunities: Data = try encodeForSaving(object: newValue)

                        do
                        {
                            try writeDataToFile(data: encodedSavedCommunities, fileURL: AppConstants.savedCommunitiesFilePath)
                        }
                        catch let writingError
                        {
                            print("Failed while saving data to file: \(writingError)")
                        }
                    }
                    catch let encodingError
                    {
                        print("Failed while encoding communities to data: \(encodingError)")
                    }
                }
                .onAppear
                {
                    if FileManager.default.fileExists(atPath: AppConstants.savedCommunitiesFilePath.path)
                    {
                        print("Saved Communities file exists, will attempt to load saved communities")
                        
                        do
                        {
                            communitiesTracker.savedCommunities = try decodeCommunitiesFromFile(fromURL: AppConstants.savedCommunitiesFilePath)
                        }
                        catch let savedCommunityDecodingError
                        {
                            print("Failed while decoding saved communities: \(savedCommunityDecodingError)")
                        }
                    }
                    else
                    {
                        print("Saved Communities file does not exist, will try to create it")
                        
                        do
                        {
                            try createEmptyFile(at: AppConstants.savedCommunitiesFilePath)
                        }
                        catch let emptyFileCreationError
                        {
                            print("Failed while creating an empty file: \(emptyFileCreationError)")
                        }
                    }
                }
        }
    }
}
