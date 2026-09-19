//
//  MediaTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-05-23.
//

import Foundation
import Media

private class WeakMediaControlState {
    weak var value: MediaControlState?
    
    public init(_ value: MediaControlState) {
        self.value = value
    }
}

@Observable
public class MediaTracker {

    private var controlStates: [URL: WeakMediaControlState] = .init()
    
    // These must not be observable. See https://github.com/mlemgroup/mlem/issues/2974
    @ObservationIgnored private var lastCleaned: Date = .init()
    @ObservationIgnored private let cleanInterval: TimeInterval = 60
    
    @available(*, deprecated, message: "Access the MediaTracker from the environment where possible.")
    public static var main: MediaTracker = .init()
    
    public func controlState(for url: URL?, create: () -> MediaControlState) -> MediaControlState {
        defer {
            if Date().timeIntervalSince(lastCleaned) > cleanInterval {
                clean()
            }
        }
        
        // control states can exist with nil URLs, but it doesn't make sense to store them here.
        // it is incumbent on the caller to ensure that if the URL becomes non-nil it is added with addAlias
        guard let url else { return create() }
        
        if let existing = controlStates[url]?.value {
            return existing
        }
        let new = create()
        controlStates[url] = .init(new)
        return new
    }

    private func clean() {
        for key in controlStates.keys where controlStates[key]?.value == nil {
            controlStates.removeValue(forKey: key)
        }
        self.lastCleaned = .now
    }
    
    public func addAlias(for url: URL, controlState: MediaControlState) {
        controlStates[url] = .init(controlState)
    }
}
