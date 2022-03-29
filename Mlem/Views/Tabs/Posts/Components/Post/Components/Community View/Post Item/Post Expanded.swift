//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Post_Expanded: View {
    
    @ObservedObject var connectionHandler = LemmyConnectionHandler(instanceAddress: "hexbear.net")
    
    let postID: Int
    
    var body: some View {
        VStack {
            Text(String(postID))
            
            if connectionHandler.isLoading {
                ProgressView()
            } else {
                Text(connectionHandler.receivedData)
            }
            
        }
        .onAppear {
            Task {
                await connectionHandler.sendCommand(maintainOpenConnection: false, command: """
                    {"op": "GetPost", "data": {"id": \(postID)}}
                    """)
            }
        }
    }
}
