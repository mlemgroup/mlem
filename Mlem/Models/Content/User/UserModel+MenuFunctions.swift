//
//  UserModel+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 10/11/2023.
//

import Foundation

extension UserModel {
    func blockMenuFunction(_ callback: @escaping (_ item: Self) -> Void = { _ in }) -> MenuFunction {
        .standardMenuFunction(
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
        modToolTracker: ModToolTracker
    ) -> MenuFunction {
        .standardMenuFunction(
            text: banned ? "Unban" : "Ban",
            imageName: Icons.instanceBan,
            role: .destructive(prompt: banned ? "Really unban this user?" : nil),
            callback: {
                if banned {
                    // TODO: ERIC unban reason
                    Task {
                        var new = self
                        await new.toggleBan(callback)
                    }
                } else {
                    // editorTracker.banUser = BanUserEditorModel(user: self, callback: callback)
                    modToolTracker.banUserFromInstance(self)
                }
            }
        )
    }
    
    func menuFunctions(
        _ callback: @escaping (_ item: Self) -> Void = { _ in },
        modToolTracker: ModToolTracker? = nil
    ) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        do {
            if let instanceHost = profileUrl.host() {
                let instance: InstanceModel
                if let site {
                    instance = .init(from: site)
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
                text: "Copy Username",
                imageName: Icons.copy,
                callback: copyFullyQualifiedUsername
            )
        )
        functions.append(.shareMenuFunction(url: profileUrl))
        
        let isOwnUser = (siteInformation.myUser?.userId ?? -1) == userId
        
        if !isOwnUser {
            functions.append(blockMenuFunction(callback))
            if siteInformation.myUser?.isAdmin ?? false, !(isAdmin ?? false), let modToolTracker {
                functions.append(banMenuFunction(callback, modToolTracker: modToolTracker))
            }
        }
        return functions
    }
}
