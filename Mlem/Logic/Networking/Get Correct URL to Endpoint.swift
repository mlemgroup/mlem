//
//  Get Correct URL to Endpoint.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

fileprivate enum EndpointDiscoveryError: Error
{
    case couldNotFindAnyCorrectEndpoints
}

func getCorrectURLtoEndpoint(baseInstanceAddress: String) async throws -> URL
{
    var validAddress: URL?
    
    let possibleInstanceAddresses: [URL] = [
        URL(string: "wss://www.\(baseInstanceAddress)/api/v1/ws")!,
        URL(string: "wss://www.\(baseInstanceAddress)/api/v2/ws")!,
        URL(string: "wss://www.\(baseInstanceAddress)/api/v3/ws")!,
        URL(string: "wss://\(baseInstanceAddress)/api/v1/ws")!,
        URL(string: "wss://\(baseInstanceAddress)/api/v2/ws")!,
        URL(string: "wss://\(baseInstanceAddress)/api/v3/ws")!
    ]
    
    for address in possibleInstanceAddresses
    {
        print("Will check \(address)")
        if await checkIfWebSocketEndpointExists(at: address)
        {
            print("\(address) is valid")
            validAddress = address
            
            break
        }
        else
        {
            print("\(address) is invalid")
            continue
        }
    }
    
    if let validAddress
    {
        return validAddress
    }
    else
    {
        throw EndpointDiscoveryError.couldNotFindAnyCorrectEndpoints
    }
}
