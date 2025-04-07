//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-06.
//

import Foundation

public extension Icon {
    struct GeneralIcons {
        public let success: Icon = .applyCircle("checkmark")
        public let failure: Icon = .applyCircle("xmark")
        
        @inlinable public var present: Icon { success }
        public let absent: Icon = .baseOnly("circle")
        
        public let warning: Icon = .applyFill("exclamationmark.triangle")
        public let error: Icon = .applyFill("exclamationmark.circle")
        
        public let hide: Icon = .applyFill("eye.slash")
        public let show: Icon = .applyFill("eye")
        
        public let time: Icon = .applyFill("clock")
        public let updateTime: Icon = .baseOnly("clock.arrow.2.circlepath")
        
        public let close: Icon = .applyCircle("multiply")
        public let add: Icon = .applyCircle("plus")
        public let website: Icon = .applyFill("globe")
        
        public let undo: Icon = .applyCircle("arrow.uturn.backward")
        public let redo: Icon = .applyCircle("arrow.uturn.forward")
    }
    
    static let general: GeneralIcons = .init()
}
