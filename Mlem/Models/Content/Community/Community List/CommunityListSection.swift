//
//  CommunityListSection.swift
//  Mlem
//
//  Created by Jake Shirey on 17.06.2023.
//

import Dependencies
import SwiftUI

struct CommunityListSection: Identifiable {
    let id = UUID()
    let viewId: String
    let sidebarEntry: any SidebarEntry
    let inlineHeaderLabel: String?
    let accessibilityLabel: String
    let communities: [APICommunity]
}
