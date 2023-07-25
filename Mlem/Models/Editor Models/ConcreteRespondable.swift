//
//  ConcreteEditorModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-14.
//

import Foundation
import SwiftUI

enum ResponseOperation {
    case reply, report, edit
}

/**
 Concrete model representing a respondable thing. Needed so that sheets can be presented using the item: syntax, since Respondable is a protocol and therefore cannot be Identifiable.
 */
struct ConcreteEditorModel: Identifiable {
    var id: Int { editorModel.id }
    let editorModel: any EditorModel

    init(editorModel: any EditorModel) {
        self.editorModel = editorModel
    }
}

// MARK: Convenience Initializers
extension ConcreteEditorModel {
    /**
     Create a ConcreteRespondable to reply to or report a post without a post tracker
     */
    init(appState: AppState, post: APIPostView, operation: ResponseOperation) {
        switch operation {
        case .reply: self.editorModel = ReplyToFeedPost(appState: appState, post: post)
        case .report: self.editorModel = ReportPost(appState: appState, post: post)
        default:
            assertionFailure("editing not supported yet")
            // shouldn't ever get here, but it makes the compiler happy
            self.editorModel = ReplyToFeedPost(appState: appState, post: post)
        }
    }

    /**
     Create a ConcreteRespondable to reply to, report, or edit a comment with a comment tracker (i.e., in a threaded comments section)
     */
    init(appState: AppState, comment: APICommentView, commentTracker: CommentTracker, operation: ResponseOperation) {
        switch operation {
        case .reply: self.editorModel = ReplyToComment(appState: appState,
                                                       comment: comment,
                                                       commentTracker: commentTracker)
        case .report: self.editorModel = ReportComment(appState: appState,
                                                       comment: comment)
        case .edit: self.editorModel = CommentEditor(appState: appState,
                                                     comment: comment,
                                                     commentTracker: commentTracker)
        }
    }

    /**
     Create a ConcreteRespondable to post a comment to a post in comments
     */
    init(appState: AppState, post: APIPostView, commentTracker: CommentTracker) {
        self.editorModel = ReplyToExpandedPost(appState: appState, post: post, commentTracker: commentTracker)
    }

    /**
     Create a ConcreteRespondable to reply to or report a comment without tracker
     
     NOTE: can be used to report comments in comments view, since reporting does not update comment tracker
     */
    init(appState: AppState, comment: APICommentView, report: Bool = false) {
        if report {
            self.editorModel = ReportComment(appState: appState, comment: comment)
        } else {
            self.editorModel = ReplyToComment(appState: appState, comment: comment, commentTracker: nil)
        }
    }

    /**
     Create a ConcreteRespondable to reply to or report a comment reply
     */
    init(appState: AppState, commentReply: APICommentReplyView, report: Bool = false) {
        if report {
            self.editorModel = ReportCommentReply(appState: appState, commentReply: commentReply)
        } else {
            self.editorModel = ReplyToCommentReply(appState: appState, commentReply: commentReply)
        }
    }

    /**
     Create a ConcreteRespondable to reply to or report a mention
     */
    init(appState: AppState, mention: APIPersonMentionView, report: Bool = false) {
        if report {
            self.editorModel = ReportMention(appState: appState, mention: mention)
        } else {
            self.editorModel = ReplyToMention(appState: appState, mention: mention)
        }
    }

    /**
     Create a ConcreteRespondable to reply to or report a message
     */
    init(appState: AppState, message: APIPrivateMessageView, report: Bool = false) {
        if report {
            self.editorModel = ReportMessage(appState: appState, message: message)
        } else {
            self.editorModel = ReplyToMessage(appState: appState, message: message)
        }
    }
}
