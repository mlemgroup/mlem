//
//  Interactable2Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/08/2024.
//

import MlemMiddleware

extension Interactable2Providing {
    func contextualFlairs() -> Set<PersonFlair> {
        var output: Set<PersonFlair> = []
        if creatorIsAdmin ?? api.myInstance?.administrators.contains(where: { $0.id == id }) ?? false {
            output.insert(.admin)
        }
        if creatorIsModerator ?? false {
            output.insert(.moderator)
        }
        if bannedFromCommunity ?? false {
            output.insert(.bannedFromCommunity)
        }
        if let comment = self as? any Comment2Providing {
            if let post = comment.post_, comment.creatorId == post.creatorId {
                output.insert(.op)
            }
        }
        return output
    }
    
    func showRemoveSheet() {
        NavigationModel.main.openSheet(.remove(self))
    }
    
    var canModerate: Bool {
        api.myPerson?.moderates(communityId: community.id) ?? false || api.isAdmin
    }
    
    func toggleRemoved(reason: String?, feedback: Set<FeedbackType>) {
        Task {
            let initialValue = removed
            if feedback.contains(.haptic) {
                await HapticManager.main.play(haptic: .success, priority: .low)
            }
            switch await self.toggleRemoved(reason: reason).result.get() {
            case .failed:
                ToastModel.main.add(.failure(initialValue ? "Failed to remove content" : "Failed to restore content"))
            default:
                break
            }
        }
    }
    
    func removeAction(feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "remove\(uid)",
            appearance: .remove(isOn: removed, isInProgress: !removedManager.isInSync),
            callback: api.canInteract && canModerate ? showRemoveSheet : nil
        )
    }
}
