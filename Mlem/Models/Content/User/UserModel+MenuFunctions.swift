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
        do {
            if let instanceHost = self.profileUrl.host() {
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
