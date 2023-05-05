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
    #warning("Hexbear uses v1 of the API, while all other Lemmy instances use v3. Hexbear is also the only instance that uses the www prefix, all other instances don't have www")
    guard let finalInstanceAddress = URL(string: "wss://www.\(instanceAddress)/api/v1/ws") else { throw ConnectionError.failedToEncodeAddress }
    
    print("Instance address: \(finalInstanceAddress)")
    
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
            task.cancel(with: .policyViolation, reason: nil)
            throw ConnectionError.receivedInvalidResponseFormat
            
        @unknown default:
            print("Unknown response received")
            task.cancel(with: .policyViolation, reason: nil)
            throw ConnectionError.receivedInvalidResponseFormat
    }
}
