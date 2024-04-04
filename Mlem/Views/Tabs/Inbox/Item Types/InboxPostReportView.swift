//
//  InboxPostReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import SwiftUI

struct InboxPostReportView: View {
    @ObservedObject var postReport: PostReportModel
    
    var body: some View {
        InboxPostReportBodyView(postReport: postReport)
    }
}
