//
//  Networking.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import Foundation
import Starscream

class LemmyWebSocket: NSObject, URLSessionWebSocketDelegate {
    private var webSocket: URLSessionWebSocketTask?
    
    override init() {
        super.init()
        let lemmyInstanceLink: String = "hexbear.net" // This is the base URL for the lemmy instance. eg "hexbear.net"
        
        let session = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        
        let lemmyInstanceURL: URL = URL(
            string: "wss://www.\(lemmyInstanceLink)/api/v1/ws"
        )! // Make that base URL into an URL type for the WebSocket to work
        
        let webSocket = session.webSocketTask(with: lemmyInstanceURL)
        webSocket.resume()
    }
    
    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping error: \(error)")
            }
        })
    }
    
    func close() {
        webSocket?.cancel(with: .goingAway, reason: "Closed connection willingly".data(using: .utf8))
    }
    
    func send() {
        webSocket?.send(.string("Sent debug message"), completionHandler: {error in
            if let error = error {
                print("Send error: \(error)")
            }
        })
    }
    
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Received data: \(data)")
                case .string(let string):
                    print("Received string: \(string)")
                @unknown default:
                    break
                }
            case.failure(let error):
                print("Receive error: \(error)")
            }
            self?.receive()
        })
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket Connected!")
        ping()
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket Closed!")
    }
}
