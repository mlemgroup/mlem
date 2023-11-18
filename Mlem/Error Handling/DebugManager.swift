//
//  DebugManager.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-18.
//

import Foundation

/// Class to unify storing and retrieving debug information so that users can file more informative bug reports.
/// Maintains a cache of up to 100 debugEvents; at present, those are a simple String containing debug information, but this model could be easily extended to capture more sophisticated debug information.
/// For simplicity, interaction with the cache is controlled by registerDebugEvent and retrieveDebugEvent; externally, debug events are a map of UUID to String, and this class handles the ugly work of converting that to the NSCache-friendly NSString:NSString map that actually exists.
class DebugManager {
    private var debugEvents: NSCache<NSString, NSString>
    
    init() {
        self.debugEvents = .init()
        debugEvents.countLimit = 100
    }
    
    func registerDeugEvent(debugInfo: String) -> UUID {
        print("registered debug event")
        let debugId = UUID()
        debugEvents.setObject(NSString(string: debugInfo), forKey: NSString(string: debugId.uuidString))
        return debugId
    }
    
    func retrieveDebugEvent(id: UUID) -> String? {
        debugEvents.object(forKey: NSString(string: id.uuidString)) as String?
    }
}
