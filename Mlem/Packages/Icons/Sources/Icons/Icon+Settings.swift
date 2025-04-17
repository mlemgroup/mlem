//
//  File.swift
//  Icons
//
//  Created by Sjmarf on 2025-04-06.
//

import Foundation

public extension Icon {
    struct SettingsIcons {
        public let hideRead: Icon = .init("book")
        @inlinable public var showRead: Icon { hideRead }
        
        public let postSize: Icon = .init("rectangle.expand.vertical")
        public let postSizeCompact: Icon = .init("rectangle.grid.1x2")
        public let postSizeTiled: Icon = .init("rectangle.grid.2x2")
        public let postSizeHeadline: Icon = .init("rectangle")
        public let postSizeLarge: Icon = .init("text.below.photo")
        
        public let blurNsfw: Icon = .init("eye.trianglebadge.exclamationmark")
        public let upvoteOnSave: Icon = .init("arrow.up.heart")
        public let readIndicatorSetting: Icon = .init("book")
        public let readIndicatorBarSetting: Icon = .init("rectangle.leftthird.inset.filled")
        public let profileTabSettings: Icon = .init("person.text.rectangle")
        public let nicknameField: Icon = .init("rectangle.and.pencil.and.ellipsis")
        public let label: Icon = .init("tag")
        public let unreadBadge: Icon = .init("envelope.badge")
        public let showAvatar: Icon = .init("person.fill.questionmark")
        public let widgetWizard: Icon = .init("wand.and.stars")
        public let thumbnail: Icon = .init("photo")
        public let author: Icon = .init("signature")
        public let leftRight: Icon = .init("arrow.left.arrow.right")
        public let developerMode: Icon = .init("wrench.adjustable.fill")
        public let limitImageHeightSetting: Icon = .init("rectangle.compress.vertical")
        public let appLockSettings: Icon = .init("lock.app.dashed")
        public let logIn: Icon = .init("person.text.rectangle")
        public let signUp: Icon = .init("pencil.and.list.clipboard")
        public let sidebar: Icon = .init("sidebar.left")
        public let infiniteScroll: Icon = .init("infinity")
        public let markReadOnScroll: Icon = .init("book")
        public let confirmImageUploads: Icon = .init("photo.badge.checkmark")
        public let swipeActions: Icon = .init("inset.filled.leadinghalf.rectangle")
        public let swipeAnywhere: Icon = .init("arrow.left")
        public let importSettings: Icon = .init("folder.badge.gearshape")
        public let inApp: Icon = .init("house")
        public let reader: Icon = .init("text.page")
        public let keywordFilter: Icon = .init("rectangle.and.text.magnifyingglass")
        public let saveSettings: Icon = .init("document.badge.gearshape")
        public let restoreSettings: Icon = .init("gearshape.arrow.trianglehead.2.clockwise.rotate.90")
        public let menuItems: Icon = .init("filemenu.and.selection")
        public let systemMode: Icon = .init("circle.lefthalf.filled")
        public let lightMode: Icon = .init("sun.max")
        public let darkMode: Icon = .init("moon")
        public let compactComments: Icon = .init("rectangle.compress.vertical")
        public let interactionBar: Icon = .init("square.and.line.vertical.and.square.fill")
        public let commentDepth: Icon = .init("text.append")
        public let qualifiedLabel: Icon = .init("at")
        public let right: Icon = .init("arrow.right")
        public let left: Icon = .init("arrow.left")
        public let center: Icon = .init("dot")
        public let zoomSlider: Icon = .init("arrow.up.and.down.and.sparkles")
        public let language: Icon = .init("globe")
        public let settingsIcons: Icon = .init("fleuron")
        public let privacy: Icon = .init("hand.raised")
        public let openExternalLinks: Icon = .init("arrow.up.right")
        public let tappableLinks: Icon = .init("hand.tap")
        public let general: Icon = .init("gear")
        public let safety: Icon = .init("shield.lefthalf.filled")
        public let accessibility: Icon = .init("hand.point.up.braille.fill")
        public let sorting: Icon = .init("arrow.up.and.down.text.horizontal")
        public let tabBar: Icon = .init("platter.filled.bottom.iphone")
        public let advanced: Icon = .init("gearshape.2.fill")
        public let localAccountOptions: Icon = .init("iphone")
        public let eula: Icon = .init("doc.plaintext")
        public let licence: Icon = .init("doc")
        public let ask: Icon = .init("questionmark.circle")
        public let jumpButton: Icon = .init("chevron.down.circle")
    }
    
    static let settings: SettingsIcons = .init()
}
