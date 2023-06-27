//
//  Check if Endpoint Exists.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

func checkIfEndpointExists(at url: URL) async -> Bool {
    var request: URLRequest = URLRequest(url: url)

    request.httpMethod = "GET"

    do {
        let (_, response) = try await AppConstants.urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }

        return httpResponse.statusCode == 400
    } catch {
        return false
    }
}
