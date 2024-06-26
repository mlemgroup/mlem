//
//  CommunityModel+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 09/11/2023.
//

import Foundation
import SwiftUI

extension CommunityModel {
    func newPostMenuFunction(editorTracker: EditorTracker, postTracker: StandardPostTracker? = nil) -> MenuFunction {
        .standardMenuFunction(
            text: "New Post",
            imageName: Icons.sendFill,
            enabled: true
        ) {
            editorTracker.openEditor(with: PostEditorModel(
                community: self,
                postTracker: postTracker
            ))
        }
    }
    
    func subscribeMenuFunction(_ callback: @escaping (_ item: Self) -> Void = { _ in }) throws -> MenuFunction {
        guard let subscribed else {
            throw CommunityError.noData
        }
        let callback = {
            Task {
                do {
                    try await self.toggleSubscribe(callback)
                } catch {
                    errorHandler.handle(error)
                }
            }
            return ()
        }
        
        if subscribed {
            return .standardMenuFunction(
                text: "Unsubscribe",
                imageName: Icons.unsubscribe,
                confirmationPrompt: "Are you sure you want to unsubscribe from \(name!)?",
                callback: callback
            )
        }
        return .standardMenuFunction(
            text: "Subscribe",
            imageName: Icons.subscribe,
            callback: callback
        )
    }
    
    func favoriteMenuFunction(_ callback: @escaping (_ item: Self) -> Void = { _ in }) -> MenuFunction {
        let callback = {
            Task {
                do {
                    try await self.toggleFavorite(callback)
                } catch {
                    errorHandler.handle(error)
                }
            }
            return ()
        }
        
        if favorited {
            return .standardMenuFunction(
                text: "Unfavorite",
                imageName: Icons.unfavorite,
                confirmationPrompt: "Really unfavorite \(name ?? "this community")?",
                callback: callback
            )
        }
        return .standardMenuFunction(text: "Favorite", imageName: Icons.favorite, callback: callback)
    }
    
    func blockCallback(_ callback: @escaping (_ item: Self) -> Void = { _ in }) {
        let blocked = blocked ?? false
        Task {
            do {
                var new = self
                try await new.toggleBlock(callback)
                if new.blocked != blocked {
                    await notifier.add(.success("\(blocked ? "Unblocked" : "Blocked") community"))
                } else {
                    await notifier.add(.failure("Failed to \(blocked ? "block" : "block") community"))
                }
            } catch {
                errorHandler.handle(error)
            }
        }
    }
    
    func blockMenuFunction(_ callback: @escaping (_ item: Self) -> Void = { _ in }) throws -> MenuFunction {
        guard let blocked else {
            throw CommunityError.noData
        }
        
        if blocked {
            return .standardMenuFunction(text: "Unblock", imageName: Icons.show, callback: { blockCallback(callback) })
        }
        return .standardMenuFunction(
            text: "Block",
            imageName: Icons.hide,
            confirmationPrompt: AppConstants.blockCommunityPrompt,
            callback: { blockCallback(callback) }
        )
    }
    
    // swiftlint:disable:next function_body_length
    func menuFunctions(
        editorTracker: EditorTracker? = nil,
        postTracker: StandardPostTracker? = nil,
        modToolTracker: ModToolTracker? = nil,
        _ callback: @escaping (_ item: Self) -> Void = { _ in }
    ) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        if let editorTracker {
            functions.append(newPostMenuFunction(editorTracker: editorTracker, postTracker: postTracker))
        }
        if let function = try? subscribeMenuFunction(callback) {
            functions.append(function)
            functions.append(favoriteMenuFunction(callback))
        }
        do {
            if let instanceHost = communityUrl.host() {
                var instance: InstanceModel
                if let site {
                    instance = .init(from: site, isLocal: true)
                } else {
                    instance = try .init(domainName: instanceHost)
                }
                functions.append(
                    .navigationMenuFunction(
                        text: instanceHost,
                        imageName: Icons.instance,
                        destination: .instance(instance)
                    )
                )
            }
        } catch {
            print("Failed to add instance menu function!")
        }
        functions.append(
            .standardMenuFunction(
                text: "Copy Name",
                imageName: Icons.copy,
                callback: copyFullyQualifiedName
            )
        )
        functions.append(.shareMenuFunction(url: communityUrl))
        if let function = try? blockMenuFunction(callback) {
            functions.append(function)
        }
        
        if siteInformation.isAdmin, let modToolTracker {
            functions.append(.divider)
            functions.append(
                .toggleableMenuFunction(
                    toggle: removed,
                    trueText: "Restore",
                    trueImageName: Icons.restore,
                    falseText: "Remove",
                    falseImageName: Icons.remove,
                    isDestructive: .whenFalse,
                    callback: {
                        modToolTracker.removeCommunity(self, shouldRemove: !removed)
                    }
                )
            )
            functions.append(
                .standardMenuFunction(text: "Purge", imageName: Icons.purge, isDestructive: true) {
                    modToolTracker.purgeContent(self)
                }
            )
        }
        
        return functions
    }
}
