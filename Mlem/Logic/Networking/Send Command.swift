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

func sendCommand(maintainOpenConnection: Bool, instanceAddress: URL, command: String) async throws -> String
{
    print("Instance address: \(instanceAddress)")
    print("Will send command \(command)")
    
    let session = URLSession(configuration: .default)

    let task: URLSessionWebSocketTask = session.webSocketTask(with: instanceAddress)

    let finalCommand = URLSessionWebSocketTask.Message.string(command)
    
    task.resume()
    
    try await task.send(finalCommand)
    
    let response = try await task.receive()
    
    switch response
    {
        case let .string(responseString):
            print("Received a valid string")
            
            if !maintainOpenConnection
            {
                task.cancel(with: .goingAway, reason: nil)
            }
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
