//
//  Networking.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import Foundation
import Starscream

class LemmyConnector: WebSocketDelegate {
    let instanceURL: String
    let instanceAPIUrl: URL
    
    var isConnected: Bool
    
    init(instanceURL: String) {
        self.instanceURL = instanceURL
        self.instanceAPIUrl = URL(string: "wss://www.\(instanceURL)/api/v1/ws")!
        self.isConnected = false
        
        var request = URLRequest(url: instanceAPIUrl)
        request.timeoutInterval = 5
        
        let socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
        print("WS Client Setup Done")
        print("Will attempt to connect to API URL [\(instanceAPIUrl)]")
    }
    
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            self.isConnected = true
            print("Socket Connected! Headers: \(headers)")
        case .disconnected(let reason, let code):
            self.isConnected = false
            print("Socket disconnected! Reason: \(reason) with code \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .pong(let optional):
            break
        case .ping(let optional):
            break
        case .error(let error):
            self.isConnected = false
            handleError(error)
        case .viabilityChanged(let bool):
            break
        case .reconnectSuggested(let bool):
            break
        case .cancelled:
            self.isConnected = false
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("Websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("Websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("Websocket encountered an error")
        }
    }
}
