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
        
        public let share: Icon = .baseOnly("square.and.arrow.up")
        public let search: Icon = .custom { variant in
            switch variant {
            case .active: "text.magnifyingglass"
            default: "magnifiyingglass"
            }
        }

        public let settings: Icon = .baseOnly("gear")
        public let filter: Icon = .applyFill("line.3.horizontal.decrease.circle")
        public let menu: Icon = .baseOnly("ellipsis")
        public let menuCircle: Icon = .applyFill("ellipsis.circle")
        public let `import`: Icon = .baseOnly("square.and.arrow.down")
        public let edit: Icon = .baseOnly("pencil")
        public let delete: Icon = .applyFill("trash")
        public let undelete: Icon = .applyFill("trash.slash")
        
        public let copy: Icon = .applyFill("doc.on.doc")
        public let paste: Icon = .applyFill("doc.on.clipboard")
        public let signOut: Icon = .applyFill("minus.circle")
        public let refresh: Icon = .baseOnly("arrow.clockwise")
        public let select: Icon = .baseOnly("selection.pin.")
    }
    
    static let general: GeneralIcons = .init()
}
