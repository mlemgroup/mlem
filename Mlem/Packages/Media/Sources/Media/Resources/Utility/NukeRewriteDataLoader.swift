//
//  NukeRewriteDataLoader.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-19.
//

import Foundation
import Nuke

struct NukeRewriteDataLoader: DataLoading {
    let base: any DataLoading

    init() {
        self.base = DataLoader(configuration: .default)
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
        var request = request
        request.setValue("MlemUserAgent", forHTTPHeaderField: "User-Agent")
        if let url = request.url, url.pathExtension.lowercased() == "gifv" {
            request.url = url.deletingPathExtension().appendingPathExtension("mp4")
        }
        return request
    }
}
