//
//  InboxView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-20.
//

import Foundation

extension InboxView {
    func filterRead() {
        assertionFailure("implement me")
    }
    
    func markAllAsRead() {
        assertionFailure("implement me")
    }
    
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        let (filterReadText, filterReadSymbol) = shouldFilterRead
            ? ("Show All", Icons.filterFill)
            : ("Show Only Unread", Icons.filter)
        
        ret.append(MenuFunction.standardMenuFunction(
            text: filterReadText,
            imageName: filterReadSymbol,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await filterRead()
            }
        })
        
        ret.append(MenuFunction.standardMenuFunction(
            text: "Mark All as Read",
            imageName: "envelope.open",
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await markAllAsRead()
            }
        })
        
        return ret
    }
}
