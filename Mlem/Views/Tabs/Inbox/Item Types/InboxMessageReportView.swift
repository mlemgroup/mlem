//
//  InboxMessageReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation
import SwiftUI

struct InboxMessageReportView: View {
    @ObservedObject var messageReport: MessageReportModel
    
    var body: some View {
        InboxMessageReportBodyView(messageReport: messageReport)
    }
}
