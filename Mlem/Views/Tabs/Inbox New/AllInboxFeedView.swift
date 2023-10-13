//
//  AllInboxFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-28.
//
import Foundation
import SwiftUI

struct AllInboxFeedView: View {
    @ObservedObject var inboxTracker: InboxTrackerNew

    var body: some View {
        ForEach(inboxTracker.items) { item in
            VStack(spacing: 0) {
                Text("item \(item.id)")

                Divider()
            }
        }
    }
}
