//
//  Establish Connection to Instance.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import Foundation
import SwiftUI

class LemmyConnectionHandler: ObservableObject
{
    let instanceAddress: String

    @Published var isLoading = true
    @Published var receivedData: String = ""

    private let APIAddress: URL
    private let session = URLSession(configuration: .default)

    init(instanceAddress: String)
    {
        self.instanceAddress = instanceAddress

        APIAddress = URL(string: "wss://www.\(instanceAddress)/api/v1/ws")!
    }

    func sendCommand(maintainOpenConnection: Bool, command: String)
    {
        // TODO: Maybe remove this
        /* if self.receivedData != "" { // Flush the already existing data
             self.receivedData = ""
         } */

        // print("Function successfully called")

        // print("Will attempt to send command \(command) to \(APIAddress)")

        let webSocketTask = session.webSocketTask(with: APIAddress)

        let convertedCommand = URLSessionWebSocketTask.Message.string(command)

        webSocketTask.resume()

        // print("Converted command, will try to send the command")

        webSocketTask.send(convertedCommand)
        { error in
            if let error = error
            {
                print("WebSocket sending error: \(error)")
            }
            else
            {
                webSocketTask.receive
                { result in
                    switch result
                    {
                    case let .failure(error):
                        print("Failed to receive message: \(error)")

                    case let .success(message):
                        switch message
                        {
                        case let .string(text):
                            print("Received TEXT message: \(text)")
                            DispatchQueue.main.async
                            {
                                self.receivedData = text
                            }
                        case let .data(data):
                            print("Received BINARY message: \(data)")
                            fatalError()
                        }

                        DispatchQueue.main.async
                        {
                            self.isLoading = false
                        }

                        if maintainOpenConnection == false
                        {
                            print("Data received, closing connection")
                            webSocketTask.cancel(with: .goingAway, reason: nil)
                        }
                        else
                        {
                            webSocketTask.resume() // TODO: This doesn't actually do anything. Make it work.
                        }
                    }
                }
            }
        }
    }
}
