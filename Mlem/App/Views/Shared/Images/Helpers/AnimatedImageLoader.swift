//
//  AnimatedImageLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-21.
//

import SwiftUI

@Observable
class AnimatedImageLoader: ImageLoading {
    private(set) var url: URL?
    private(set) var data: Data?
    private(set) var loading: ImageLoadingState
    private(set) var error: ImageLoadingError?
    
    var uiImage: UIImage? { nil }

    init() {
        self.loading = .loading
    }
    
    func load() async {
        // noop
    }
    
    func bypassProxy() async {
        // noop
    }
}
