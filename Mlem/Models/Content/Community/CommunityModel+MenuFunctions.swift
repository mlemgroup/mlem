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
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            editorTracker.openEditor(with: PostEditorModel(
                community: self,
                postTracker: postTracker
            ))
        }
    }
    
    func subscribeMenuFunction(_ callback: @escaping (_ item: Self) -> Void = { _ in }) throws -> StandardMenuFunction {
        guard let subscribed else {
            throw CommunityError.noData
        }
        return .init(
            text: subscribed ? "Unsubscribe" : "Subscribe",
            imageName: subscribed ? Icons.unsubscribe : Icons.subscribe,
            destructiveActionPrompt: subscribed ? "Are you sure you want to unsubscribe from \(name!)?" : nil,
            enabled: true,
            callback: {
                Task {
                    do {
                        try await self.toggleSubscribe(callback)
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            }
        )
    }
    
    func favoriteMenuFunction(_ callback: @escaping (_ item: Self) -> Void = { _ in }) -> StandardMenuFunction {
        .init(
            text: favorited ? "Unfavorite" : "Favorite",
            imageName: favorited ? Icons.unfavorite : Icons.favorite,
            destructiveActionPrompt: favorited ? "Really unfavorite \(name ?? "this community")?" : nil,
            enabled: true
        ) {
            Task {
                do {
                    try await self.toggleFavorite(callback)
                } catch {
                    errorHandler.handle(error)
                }
            }
        }
    }
    
    func blockMenuFunction(_ callback: @escaping (_ item: Self) -> Void = { _ in }) throws -> MenuFunction {
        guard let blocked else {
            throw CommunityError.noData
        }
        return .standardMenuFunction(
            text: blocked ? "Unblock" : "Block",
            imageName: blocked ? Icons.show : Icons.hide,
            destructiveActionPrompt: blocked ? nil : AppConstants.blockCommunityPrompt,
            enabled: true,
            callback: {
                Task {
                    do {
                        try await self.toggleBlock(callback)
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            }
        )
    }
    
    func menuFunctions(
        editorTracker: EditorTracker? = nil,
        postTracker: StandardPostTracker? = nil,
        _ callback: @escaping (_ item: Self) -> Void = { _ in }
    ) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        if let editorTracker {
            functions.append(newPostMenuFunction(editorTracker: editorTracker, postTracker: postTracker))
        }
        if let function = try? subscribeMenuFunction(callback) {
            functions.append(.standard(function))
            functions.append(.standard(favoriteMenuFunction(callback)))
        }
        if let instanceHost = communityUrl.host() {
            let instance: InstanceModel?
            if let site {
                instance = .init(from: site)
            } else {
                instance = nil
            }
            functions.append(
                .navigationMenuFunction(
                    text: instanceHost,
                    imageName: Icons.instance,
                    destination: .instance(instanceHost, instance)
                )
            )
        }
        functions.append(
            .standardMenuFunction(
                text: "Copy Name",
                imageName: Icons.copy,
                destructiveActionPrompt: nil,
                enabled: true,
                callback: copyFullyQualifiedName
            )
        )
        functions.append(.shareMenuFunction(url: communityUrl))
        if let function = try? blockMenuFunction(callback) {
            functions.append(function)
        }
        
        return functions
    }
}
