//
//  Establish Connection to Instance.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import Foundation
import Starscream

func establishConnectionToLemmyInstance(instanceURL: String) -> Void {
    let JSONEncoder = JSONEncoder()
    
    let connectedLemmyInstance: LemmyConnectorSS = LemmyConnectorSS(instanceURL: instanceURL)
    let connectedLemmyInstanceSocket: WebSocket = WebSocket(request: URLRequest(url: connectedLemmyInstance.instanceAPIUrl))
    
    let testRequest: String = """
    {"op": "ListCategories"}
    """
    
    /*let didReceiveWTF = connectedLemmyInstance.didReceive(event: .connected(["op": "ListCategories"]), client: connectedLemmyInstanceSocket)
    
    let receivedData = connectedLemmyInstance.didReceive(event: .text(testRequest), client: connectedLemmyInstanceSocket)
    
    print("Received this: \(didReceiveWTF)")
    print("Received this: \(receivedData)")
    
    print(connectedLemmyInstance.isConnected)*/
}
