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
        //try await task.sendPing() <--- This would be the most idea, but unfortunately it doesn't work for lemmy.ml and others
        
        try await task.send(URLSessionWebSocketTask.Message.string(""))
        
        return true
    }
    catch
    {
        return false
    }
}

func checkIfEndpointExists(at url: URL) async -> Bool
{
    var request: URLRequest = URLRequest(url: url)
    
    request.httpMethod = "HEAD"
    
    do
    {
        let (data , response) = try await AppConstants.urlSession.data(for: request)
        
        let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
        
        print("Response for endpoint \(url) is \(httpResponse.statusCode)")
        
        if httpResponse.statusCode == 200
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
