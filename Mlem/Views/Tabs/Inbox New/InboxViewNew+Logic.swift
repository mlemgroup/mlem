//
//  InboxViewNew+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-26.
//
import Foundation

extension InboxViewNew {
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()

        // TODO: Eric re-enable
//        let (filterReadText, filterReadSymbol) = shouldFilterRead
//            ? ("Show All", Icons.filterFill)
//            : ("Show Only Unread", Icons.filter)
//
//        ret.append(MenuFunction.standardMenuFunction(
//            text: filterReadText,
//            imageName: filterReadSymbol,
//            destructiveActionPrompt: nil,
//            enabled: true
//        ) {
//            Task(priority: .userInitiated) {
//                await filterRead()
//            }
//        })
//
//        ret.append(MenuFunction.standardMenuFunction(
//            text: "Mark All as Read",
//            imageName: "envelope.open",
//            destructiveActionPrompt: nil,
//            enabled: true
//        ) {
//            Task(priority: .userInitiated) {
//                await markAllAsRead()
//            }
//        })
        
        return ret
    }
}
