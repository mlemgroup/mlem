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
            destructiveActionPrompt: blocked ? nil : AppConstants.blockUserPrompt,
            enabled: true,
            callback: {
                Task {
                    var new = self
                    await new.toggleBlock(callback)
                }
            }
        )
    }
    
    func menuFunctions(_ callback: @escaping (_ item: Self) -> Void = { _ in }) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        functions.append(
            .standardMenuFunction(
                text: "Copy Username",
                imageName: Icons.copy,
                destructiveActionPrompt: nil,
                enabled: true,
                callback: copyFullyQualifiedUsername
            )
        )
        functions.append(.shareMenuFunction(url: profileUrl))
        if siteInformation.myUserInfo?.localUserView.person.id != userId {
            functions.append(blockMenuFunction(callback))
        }
        return functions
    }
}
