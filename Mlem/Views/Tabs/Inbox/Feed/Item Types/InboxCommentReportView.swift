//
//  InboxCommentReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-27.
//

import Foundation
import SwiftUI

struct InboxCommentReportView: View {
    @ObservedObject var commentReport: CommentReportModel
    
    var body: some View {
        VStack {
            Text(commentReport.comment.content)
            Text(commentReport.commentReport.reason)
        }
    }
}
