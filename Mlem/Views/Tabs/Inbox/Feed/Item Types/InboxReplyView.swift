//
//  InboxReplyView.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-12-21.
//

import SwiftUI

struct InboxReplyView: View {
    @ObservedObject var reply: ReplyModel
    
    var body: some View {
        InboxReplyView(reply: reply)
    }
}
