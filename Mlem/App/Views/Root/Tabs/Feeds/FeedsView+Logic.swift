//
//  FeedsView+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-12.
//

import Foundation

extension FeedsView {
    var toolbarActions: [any Action] {
        var ret: [any Action] = .init()
        
        ret.append(BasicAction(
            id: "read",
            isOn: showRead,
            label: showRead ? "Hide Read" : "Show Read",
            color: palette.primary,
            icon: Icons.read
        ) {
            showRead = !showRead
        })
        
        ret.append(ActionGroup(
            isOn: true,
            label: "Post Size",
            color: palette.primary,
            isDestructive: false,
            icon: Icons.postSizeSetting,
            displayMode: .disclosure, children: postSizeActions
        ))
        
        return ret
    }
    
    var postSizeActions: [BasicAction] {
        var ret: [BasicAction] = .init()
        
        PostSize.allCases.forEach { size in
            ret.append(.init(
                id: size.rawValue,
                isOn: postSize == size,
                label: size.label,
                color: palette.primary,
                isDestructive: false,
                icon: size.icon(filled: postSize == size),
                enabled: true
            ) {
                postSize = size
            })
        }
        
        return ret
    }
}
