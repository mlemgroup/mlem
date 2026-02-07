//
//  Interactable1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

/// Represents a post/comment that you *should* be able to interact with, but you cannot actually interact with due to the model being too low-tier.
public protocol InteractableProviding:
    AnyObject,
    ContentModel,
    ReportableProviding,
    ContentIdentifiable,
    RemovableProviding {
    var created: Date { get }
    var updated: Date? { get }
    
    var votes: ExpectedValue<VotesModel> { get }
    var saved: ExpectedValue<Bool> { get }
    var commentCount: ExpectedValue<Int> { get }
    var creator: ExpectedValue<Person> { get }
    var community: ExpectedValue<any Community> { get }
    var creatorIsAdmin: ExpectedValue<Bool> { get }
    var creatorIsModerator: ExpectedValue<Bool> { get }
    
    var updateVote: ((ScoringOperation) -> Void)? { get }
    func updateSaved(_ newValue: Bool)
    func reply(content: String, languageId: Int?) async throws -> Comment
    
    var downvotesEnabled: Bool { get }
}
