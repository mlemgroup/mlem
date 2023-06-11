//
//  Check if Endpoint Exists.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

func checkIfEndpointExists(at url: URL) async -> Bool
{
    var request: URLRequest = URLRequest(url: url)
    
    request.httpMethod = "GET"
    
    do
    {
        let (_, response) = try await AppConstants.urlSession.data(for: request)
        
        let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
        
        print("Response for endpoint \(url) is \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 400
        {
            return true
        }
        else
        {
            return false
        }
    }
    catch
    {
        return false
    }
}
