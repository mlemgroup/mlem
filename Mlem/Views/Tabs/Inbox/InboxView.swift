//
//  InboxView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-24.
//

import Foundation
import SwiftUI

enum InboxSelection: FeedType {
    case inbox
    
    var label: String {
        switch self {
        case .inbox: "Inbox"
        }
    }
        
    var subtitle: String {
        switch self {
        case .inbox: "Replies, mentions, and messages"
        }
    }
    
    var color: Color? {
        switch self {
        case .inbox: .purple
        }
    }
    
    var iconNameFill: String {
        switch self {
        case .inbox: Icons.inboxFill
        }
    }
    
    var iconScaleFactor: CGFloat {
        switch self {
        case .inbox: 0.55
        }
    }
}

struct InboxView: View {
    @State var selectedInbox: InboxSelection = .inbox
    
    var body: some View {
        Text("hi")
    }
}
