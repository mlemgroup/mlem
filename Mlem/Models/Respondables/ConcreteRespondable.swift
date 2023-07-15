//
//  RespondableModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-14.
//

import Foundation
import SwiftUI

/**
 Concrete model representing a respondable thing. Needed so that sheets can be presented using the item: syntax, since Respondable is a protocol and therefore cannot be Identifiable.
 */
struct ConcreteRespondable: Identifiable {
    var id: Int { respondable.id }
    let respondable: any Respondable
    
    init(respondable: any Respondable) {
        self.respondable = respondable
    }
}

// MARK: Convenience Initializers

extension ConcreteRespondable {
    /**
     Create a ConcreteRespondable to reply to or report a post without a comment tracker
     */
    init(appState: AppState, post: APIPostView, report: Bool = false) {
        if report {
            self.respondable = ReportPost(appState: appState, post: post)
        } else {
            self.respondable = ReplyToFeedPost(appState: appState, post: post)
        }
    }
    
    /**
     Create a ConcreteRespondable to post a comment to a comment in comments
     */
    init(appState: AppState, comment: APICommentView, commentTracker: CommentTracker) {
        self.respondable = ReplyToComment(appState: appState,
                                          comment: comment,
                                          commentTracker: commentTracker)
    }
    
    /**
     Create a ConcreteRespondable to post a comment to a post in comments
     */
    init(appState: AppState, post: APIPostView, commentTracker: CommentTracker) {
        self.respondable = ReplyToExpandedPost(appState: appState, post: post, commentTracker: commentTracker)
    }
    
    /**
     Create a ConcreteRespondable to reply to or report a comment without tracker
     
     NOTE: can be used to report comments in comments view, since reporting does not update comment tracker
     */
    init(appState: AppState, comment: APICommentView, report: Bool = false) {
        if report {
            self.respondable = ReportComment(appState: appState, comment: comment)
        } else {
            self.respondable = ReplyToComment(appState: appState, comment: comment, commentTracker: nil)
        }
    }
    
    /**
     Create a ConcreteRespondable to reply to or report a comment reply
     */
    init(appState: AppState, commentReply: APICommentReplyView, report: Bool = false) {
        if report {
            self.respondable = ReportCommentReply(appState: appState, commentReply: commentReply)
        } else {
            self.respondable = ReplyToCommentReply(appState: appState, commentReply: commentReply)
        }
    }
    
    /**
     Create a ConcreteRespondable to reply to or report a mention
     */
    init(appState: AppState, mention: APIPersonMentionView, report: Bool = false) {
        if report {
            self.respondable = ReportMention(appState: appState, mention: mention)
        } else {
            self.respondable = ReplyToMention(appState: appState, mention: mention)
        }
    }
    
    /**
     Create a ConcreteRespondable to reply to or report a message
     */
    init(appState: AppState, message: APIPrivateMessageView, report: Bool = false) {
        if report {
            self.respondable = ReportMessage(appState: appState, message: message)
        } else {
            self.respondable = ReplyToMessage(appState: appState, message: message)
        }
    }
}
