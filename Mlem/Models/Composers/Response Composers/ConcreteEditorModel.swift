//
//  ConcreteEditorModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-14.
//

import Foundation
import SwiftUI

/**
 Operations that can be performed on a comment
 */
enum CommentOperation {
    case replyToComment, reportComment, editComment
}

/**
 Operations that can be performed on a post
 */
enum PostOperation {
    case replyToPost, reportPost
}

/**
 Operations that can be performed on an inbox item
 */
enum InboxItemOperation {
    case replyToInboxItem, reportInboxItem
}

/**
 Concrete model representing a respondable thing. Needed so that sheets can be presented using the item: syntax, since Respondable is a protocol and therefore cannot be Identifiable.
 */
struct ConcreteEditorModel: Identifiable {
    var id: Int { editorModel.id }
    let editorModel: any ResponseEditorModel

    init(editorModel: any ResponseEditorModel) {
        self.editorModel = editorModel
    }
}

// MARK: Convenience Initializers
extension ConcreteEditorModel {
    /**
     Create a ConcreteEditorModel attached to a post.
     - .replyToPost: comment composer replying to the post. If commentTracker present, udpates it.
     - .reportPost: report composer reporting the post. If postTracker present, updates it.
     - .editPost: post composer editing the post.
     */
    init(appState: AppState,
         post: APIPostView,
         postTracker: PostTracker? = nil,
         commentTracker: CommentTracker? = nil,
         operation: PostOperation) {
        switch operation {
        case .replyToPost: self.editorModel = ReplyToPost(appState: appState, post: post)
        case .reportPost: self.editorModel = ReportPost(appState: appState, post: post)
        }
    }

    /**
     Create a ConcreteEditorModel attached to a comment
     - .replyToComment: comment composer replying to the comment. If commentTracker present, updates it.
     - .reportComment: report composer reporting the comment.
     - .editComment: comment compser editing the comment. If commentTracker present, updates it.
     */
    init(appState: AppState,
         comment: APICommentView,
         commentTracker: CommentTracker? = nil,
         operation: CommentOperation) {
        switch operation {
        case .replyToComment: self.editorModel = ReplyToComment(appState: appState,
                                                                comment: comment,
                                                                commentTracker: commentTracker)
        case .reportComment: self.editorModel = ReportComment(appState: appState,
                                                              comment: comment)
        case .editComment: self.editorModel = CommentEditor(appState: appState,
                                                            comment: comment,
                                                            commentTracker: commentTracker)
        }
    }
    
    /**
     Create a ConcreteEditorModel to reply to or report a comment reply
     */
    init(appState: AppState, commentReply: APICommentReplyView, operation: InboxItemOperation) {
        switch operation {
        case .replyToInboxItem: self.editorModel = ReplyToCommentReply(appState: appState, commentReply: commentReply)
        case .reportInboxItem: self.editorModel = ReportCommentReply(appState: appState, commentReply: commentReply)
        }
    }

    /**
     Create a ConcreteEditorModel to reply to or report a mention
     */
    init(appState: AppState, mention: APIPersonMentionView, operation: InboxItemOperation) {
        switch operation {
        case .replyToInboxItem: self.editorModel = ReplyToMention(appState: appState, mention: mention)
        case .reportInboxItem: self.editorModel = ReportMention(appState: appState, mention: mention)
        }
    }

    /**
     Create a ConcreteEditorModel to reply to or report a message
     */
    init(appState: AppState, message: APIPrivateMessageView, operation: InboxItemOperation) {
        switch operation {
        case .replyToInboxItem: self.editorModel = ReplyToMessage(message: message)
        case .reportInboxItem: self.editorModel = ReportMessage(message: message)
        }
    }
}
