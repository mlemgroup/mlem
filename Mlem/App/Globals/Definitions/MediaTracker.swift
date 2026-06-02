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
    
    private var lastCleaned: Date = .init()
    private let cleanInterval: TimeInterval = .init(60)
    
    public static var main: MediaTracker = .init()
    
    public func controlState(for url: URL?, create: () -> MediaControlState) -> MediaControlState {
        defer {
            if Date().timeIntervalSince(lastCleaned) > cleanInterval {
                for key in controlStates.keys where controlStates[key]?.value == nil {
                    controlStates.removeValue(forKey: key)
                }
            }
        }
        
        guard let url else { return create() }
        
        if let existing = controlStates[url]?.value {
            return existing
        }
        let new = create()
        controlStates[url] = .init(new)
        return new
    }
    
    public func addAlias(for url: URL, controlState: MediaControlState) {
        controlStates[url] = .init(controlState)
    }
}
