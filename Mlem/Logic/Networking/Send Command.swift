//
//  Send Command.swift
//  Mlem
//
//  Created by David Bureš on 03.05.2023.
//

import Foundation
import SwiftyJSON

enum ConnectionError: Error
{
    case failedToEncodeAddress, receivedInvalidResponseFormat
}

func sendCommand(maintainOpenConnection: Bool, instanceAddress: String, command: String) async throws -> String
{
    guard let finalInstanceAddress = URL(string: "wss://www.\(instanceAddress)/api/v1/ws") else { throw ConnectionError.failedToEncodeAddress }

    let session = URLSession(configuration: .default)

    let task: URLSessionWebSocketTask = session.webSocketTask(with: finalInstanceAddress)

    let finalCommand = URLSessionWebSocketTask.Message.string(command)
    
    task.resume()
    
    try await task.send(finalCommand)
    
    let response = try await task.receive()
    
    switch response
    {
        case let .string(responseString):
            print("Received a valid string")
            task.cancel(with: .goingAway, reason: nil)
            return responseString
            
        case let .data(responseData):
            print("Received this data: \(responseData)")
            throw ConnectionError.receivedInvalidResponseFormat
            
        @unknown default:
            print("Unknown response received")
            throw ConnectionError.receivedInvalidResponseFormat
    }
}
