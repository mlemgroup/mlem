//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-07-05.
//

import Foundation

public class ImageUploadDelegate: NSObject, URLSessionTaskDelegate {
    let callback: (Double) -> Void
    
    public init(callback: @escaping (Double) -> Void) {
        self.callback = callback
    }
    
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        callback(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
    }
}
