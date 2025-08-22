//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-06.
//

import Foundation

public extension Icon {
    struct GeneralIcons {
        public let circle: Icon = .init("circle")
        
        public let success: Icon = .applyCircle("checkmark")
        public let failure: Icon = .applyCircle("xmark")
        
        public let warning: Icon = .init("exclamationmark.triangle")
        public let error: Icon = .init("exclamationmark.circle")
        
        public let hide: Icon = .init("eye.slash")
        public let show: Icon = .init("eye")
        
        public let time: Icon = .init("clock")
        public let updateTime: Icon = .init("clock.arrow.2.circlepath")
        
        public let close: Icon = .applyCircle("multiply")
        public let add: Icon = .applyCircle("plus")
        public let remove: Icon = .applyCircle("minus")
        public let website: Icon = .init("globe")
        
        public let undo: Icon = .applyCircle("arrow.uturn.backward")
        public let redo: Icon = .applyCircle("arrow.uturn.forward")
        
        public let share: Icon = .init("square.and.arrow.up")
        public let search: Icon = .custom { variant in
            switch variant {
            case .active: "text.magnifyingglass"
            default: "magnifyingglass"
            }
        }

        public let settings: Icon = .init("gear")
        public let filter: Icon = .init("line.3.horizontal.decrease.circle")
        public let filterMenu: Icon = .init(.custom { _ in
            if #available(iOS 26, *) {
                "line.3.horizontal.decrease"
            } else {
                "line.3.horizontal.decrease.circle"
            }
        })
        public let menu: Icon = .init("ellipsis")
        public let toolbarMenu: Icon = .init(.custom { _ in
            if #available(iOS 26, *) {
                "ellipsis"
            } else {
                "ellipsis.circle"
            }
        })
        public let `import`: Icon = .init("square.and.arrow.down")
        public let export: Icon = .init("square.and.arrow.up")
        public let edit: Icon = .init("pencil")
        public let delete: Icon = .init("trash")
        public let undelete: Icon = .init("trash.slash")
        
        public let copy: Icon = .init("doc.on.doc")
        public let paste: Icon = .init("doc.on.clipboard")
        public let signOut: Icon = .init("minus.circle")
        public let attachment: Icon = .init("paperclip")
        public let refresh: Icon = .init("arrow.clockwise")
        public let select: Icon = .init("selection.pin.in.out")
        
        public let chooseFile: Icon = .init("folder")
        public let chooseImage: Icon = .init("photo")
        
        public let image: Icon = .init("photo")
        public let photoLibary: Icon = .init("photo.on.rectangle.angled")
        
        public let play: Icon = .init("play")
        public let playCircle: Icon = .applyCircle("play.circle")
        public let pause: Icon = .init("pause")

        @inlinable public var muted: Icon { mute }
        public let mute: Icon = .init("speaker.slash")
        public let unmute: Icon = .init("speaker.wave.2")
        
        public let collapse: Icon = .init("arrow.down.and.line.horizontal.and.arrow.up")
        public let expand: Icon = .init("arrow.up.and.line.horizontal.and.arrow.down")

        public let embedding: Icon = .init("app.connected.to.app.below.fill")
        public let movie: Icon = .init("film")
        public let email: Icon = .init("envelope")
        public let action: Icon = .init("diamond")
        public let missing: Icon = .init("questionmark.square.dashed")
        public let connection: Icon = .init("antenna.radiowaves.left.and.right")
        public let haptics: Icon = .init("circle.dotted.and.circle")
        public let noWifi: Icon = .init("wifi.slash")
        public let browser: Icon = .init("safari")
        public let dropDown: Icon = .applyCircle("chevron.down")
        public let noFile: Icon = .init("questionmark.folder")
        public let forward: Icon = .init("chevron.forward")
        public let backward: Icon = .init("chevron.backward")
        public let security: Icon = .init("key")
        public let link: Icon = .init("link")
        public let info: Icon = .init("info.circle")
    }
    
    static let general: GeneralIcons = .init()
}
