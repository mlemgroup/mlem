//
//  Establish Connection to Instance.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import Foundation
import SwiftUI

class LemmyConnectionHandler: ObservableObject {
    let instanceAddress: String
    
    @Published var isLoading = true
    @Published var receivedData: String = ""
    
    private let APIAddress: URL
    private let session = URLSession(configuration: .default)
    
    init(instanceAddress: String) {
        self.instanceAddress = instanceAddress
        
        self.APIAddress = URL(string: "wss://www.\(instanceAddress)/api/v1/ws")!
    }
    
    /*func printOwnName() {
        print("The function printed: \(APIAddress)")
    }*/
    
    func sendCommand(maintainOpenConnection: Bool, command: String) {
        // TODO: Maybe remove this
        /*if self.receivedData != "" { // Flush the already existing data
            self.receivedData = ""
        }*/
        
        //print("Function successfully called")
        
        //print("Will attempt to send command \(command) to \(APIAddress)")
        
        let webSocketTask = session.webSocketTask(with: APIAddress)
        
        let convertedCommand = URLSessionWebSocketTask.Message.string(command)
        
        webSocketTask.resume()
        
        //print("Converted command, will try to send the command")
        
        webSocketTask.send(convertedCommand) { error in
            if let error = error {
                print("WebSocket sending error: \(error)")
            } else {
                webSocketTask.receive { result in
                    switch result {
                    case .failure(let error):
                        print("Failed to receive message: \(error)")
                        
                    case .success(let message):
                        switch message {
                        case .string(let text):
                            print("Received TEXT message: \(text)")
                            self.receivedData = text
                        case .data(let data):
                            print("Received BINARY message: \(data)")
                            self.receivedData = "Received unexpected binary data"
                        }
                        
                        self.isLoading = false
                        
                        if maintainOpenConnection == false {
                            print("Data received, closing connection")
                            webSocketTask.cancel(with: .goingAway, reason: nil)
                        }
                    }
                }
            }
        }
    }
    
}
