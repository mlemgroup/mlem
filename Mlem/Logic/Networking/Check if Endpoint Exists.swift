//
//  Check if Endpoint Exists.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

func checkIfWebSocketEndpointExists(at url: URL) async -> Bool
{
    let session = URLSession(configuration: .default)
    let task = session.webSocketTask(with: url)
    task.resume()
    
    do
    {
        try await task.sendPing()
        
        return true
    }
    catch
    {
        return false
    }
}
