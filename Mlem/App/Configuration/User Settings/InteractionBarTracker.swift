//
//  InteractionBarTracker.swift
//  Mlem
//
//  Created by Sjmarf on 21/08/2024.
//

import Dependencies
import Observation

@Observable
class InteractionBarTracker {
    @ObservationIgnored @Dependency(\.persistenceRepository)
    private var persistenceRepository
    
    var postInteractionBar: PostBarConfiguration {
        get { interactionBarConfigurations.post }
        set { interactionBarConfigurations.post = newValue }
    }
    
    var commentInteractionBar: CommentBarConfiguration {
        get { interactionBarConfigurations.comment }
        set { interactionBarConfigurations.comment = newValue }
    }
    
    var replyInteractionBar: ReplyBarConfiguration {
        get { interactionBarConfigurations.reply }
        set { interactionBarConfigurations.reply = newValue }
    }
    
    var interactionBarConfigurations: InteractionBarConfigurations {
        didSet { Task.detached {
            try await self.persistenceRepository.saveInteractionBarConfigurations(self.interactionBarConfigurations)
        } }
    }
    
    init() {
        self.interactionBarConfigurations = PersistenceRepository.liveValue.loadInteractionBarConfigurations()
    }
    
    public static let main: InteractionBarTracker = .init()
}
