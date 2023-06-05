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
        URL(string: "https://\(baseInstanceAddress)/api/v1/user")!,
        URL(string: "https://\(baseInstanceAddress)/api/v2/user")!,
        URL(string: "https://\(baseInstanceAddress)/api/v3/user")!
    ]
    
    for address in possibleInstanceAddresses
    {
        if await checkIfEndpointExists(at: address)
        {
            print("\(address) is valid")
            validAddress = address.deletingLastPathComponent()
            
            print("Will use address \(validAddress)")
            
            break
        }
        else
        {
            print("\(address) is invalid")
            continue
        }
    }
    
    if validAddress != nil
    {
        return validAddress!
    }
    else
    {
        throw EndpointDiscoveryError.couldNotFindAnyCorrectEndpoints
    }
}
