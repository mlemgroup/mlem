//
//  Get Correct URL to Endpoint.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

enum EndpointDiscoveryError: Error {
    case couldNotFindAnyCorrectEndpoints
}

func getCorrectURLtoEndpoint(baseInstanceAddress: String) async throws -> URL {
    var validAddress: URL?
    
    let possibleInstanceAddresses = [
        URL(string: "https://\(baseInstanceAddress)/api/v3/user"),
        URL(string: "https://\(baseInstanceAddress)/api/v2/user"),
        URL(string: "https://\(baseInstanceAddress)/api/v1/user")
    ]
        .compactMap { $0 }
    
    for address in possibleInstanceAddresses {
        if await checkIfEndpointExists(at: address) {
            print("\(address) is valid")
            validAddress = address.deletingLastPathComponent()
            break
        } else {
            print("\(address) is invalid")
            continue
        }
    }
    
    if let validAddress {
        return validAddress
    }
    
    throw EndpointDiscoveryError.couldNotFindAnyCorrectEndpoints
}
