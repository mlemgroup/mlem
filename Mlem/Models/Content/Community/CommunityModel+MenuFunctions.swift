//
//  CommunityModel+MenuFunctions.swift
//  Mlem
//
//  Created by Sjmarf on 09/11/2023.
//

import Foundation
import SwiftUI

extension CommunityModel {
    func subscribeMenuFunction(_ callback: @escaping (_ item: Self) -> Void = { _ in }) throws -> MenuFunction {
        guard let subscribed else {
            throw CommunityError.noData
        }
        return .standardMenuFunction(
            text: subscribed ? "Unsubscribe" : "Subscribe",
            imageName: subscribed ? Icons.unsubscribe : Icons.subscribe,
            destructiveActionPrompt: subscribed ? "Are you sure you want to unsubscribe from \(name)?" : nil,
            enabled: true,
            callback: {
                Task {
                    var new = self
                    do {
                        try await new.toggleSubscribe(callback)
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            }
        )
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
                    var new = self
                    do {
                        try await new.toggleBlock(callback)
                    } catch {
                        errorHandler.handle(error)
                    }
                }
            }
        )
    }
    
    func menuFunctions(_ callback: @escaping (_ item: Self) -> Void = { _ in }) -> [MenuFunction] {
        var functions: [MenuFunction] = .init()
        if let function = try? subscribeMenuFunction(callback) {
            functions.append(function)
        }
        functions.append(.shareMenuFunction(url: communityUrl))
        if let function = try? blockMenuFunction(callback) {
            functions.append(function)
        }
        
        return functions
    }
}
