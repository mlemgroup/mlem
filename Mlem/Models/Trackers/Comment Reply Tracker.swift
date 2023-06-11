//
//  Comment Reply Tracker.swift
//  Mlem
//
//  Created by David Bureš on 31.05.2023.
//

import Foundation

class CommentReplyTracker: ObservableObject
{
    @Published var commentToReplyTo: APICommentView?
}
