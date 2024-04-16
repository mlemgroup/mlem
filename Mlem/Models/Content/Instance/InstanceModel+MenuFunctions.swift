//
//  InstanceModel+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 14/01/2024.
//

import Foundation

extension InstanceModel {
    
    func blockMenuFunction(_ callback: @escaping (_ item: Self) -> Void = { _ in }) -> MenuFunction {
        if blocked {
            return .standardMenuFunction(
                text: "Unblock",
                imageName: Icons.show,
                enabled: localSiteId != nil
            ) {
                Task { await toggleBlock(callback) }
            }
        }
        return .standardMenuFunction(
            text: "Block",
            imageName: Icons.hide,
            confirmationPrompt: AppConstants.blockInstancePrompt,
            enabled: localSiteId != nil
        ) {
            Task { await toggleBlock(callback) }
        }
    }
    
    func menuFunctions(_ callback: @escaping (_ item: Self) -> Void = { _ in }) -> [MenuFunction] {
        if let url {
            return [
                .shareMenuFunction(url: url),
                .openUrlMenuFunction(text: "View on Web", imageName: Icons.browser, destination: url),
                .divider,
                blockMenuFunction(callback)
            ]
        }
        return []
    }
}
