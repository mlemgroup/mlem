//
//  UserModel+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 10/11/2023.
//

import Foundation

extension UserModel {
    func blockMenuFunction(_ callback: @escaping (_ item: Self) -> Void = { _ in }) -> MenuFunction {
        return .standardMenuFunction(
            text: blocked ? "Unblock" : "Block",
            imageName: blocked ? Icons.show : Icons.hide,
            role: blocked ? nil : .destructive(prompt: AppConstants.blockUserPrompt),
            callback: {
                Task {
                    var new = self
                    await new.toggleBlock(callback)
                }
            }
        )
    }
    
    func banMenuFunction(
        _ callback: @escaping (_ item: Self) -> Void = { _ in },
        editorTracker: EditorTracker
    ) -> MenuFunction {
        return .standardMenuFunction(
            text: banned ? "Unban" : "Ban",
            imageName: Icons.bannedFlair,
            role: .destructive(prompt: banned ? "Really unban this user?" : nil),
            callback: {
                if banned {
                    Task {
                        var new = self
                        await new.toggleBan(callback)
                    }
                } else {
                    editorTracker.banUser = BanUserEditorModel(user: self, callback: callback)
                }
            }
        )
    }
    
    func menuFunctions(
        _ callback: @escaping (_ item: Self) -> Void = { _ in },
        editorTracker: EditorTracker? = nil
    ) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        functions.append(
            .standardMenuFunction(
                text: "Copy Username",
                imageName: Icons.copy,
                callback: copyFullyQualifiedUsername
            )
        )
        functions.append(.shareMenuFunction(url: profileUrl))
        
        let isOwnUser = (siteInformation.myUser?.userId ?? -1) == self.userId
        
        if !isOwnUser {
            functions.append(blockMenuFunction(callback))
            if siteInformation.myUser?.isAdmin ?? false, let editorTracker {
                functions.append(banMenuFunction(callback, editorTracker: editorTracker))
            }
        }
        return functions
    }
}
