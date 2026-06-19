//
//  NukeRewriteDataLoader.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-19.
//

import Foundation
import Nuke
import Rest

struct NukeRewriteDataLoader: DataLoading {
    let base: any DataLoading

    init() {
        var configuration = URLSessionConfiguration()
        configuration.httpAdditionalHeaders = ["User-Agent": URLSession.mlemUserAgent]
        self.base = DataLoader(configuration: configuration)
    }

    func loadData(
        with request: URLRequest,
        didReceiveData: @escaping (Data, URLResponse) -> Void,
        completion: @escaping (Error?) -> Void) -> any Cancellable {
            base.loadData(
                with: rewrite(request),
                didReceiveData: didReceiveData,
                completion: completion
            )
    }

    private func rewrite(_ request: URLRequest) -> URLRequest {
        if let url = request.url, url.pathExtension.lowercased() == "gifv" {
            print("Rewriting...")
            var request = request
            request.url = url.deletingPathExtension().appendingPathExtension("mp4")
            return request
        } else {
            return request
        }
    }
}
