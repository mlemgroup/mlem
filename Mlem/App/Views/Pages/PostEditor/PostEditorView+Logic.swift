//
//  PostEditorView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 20/08/2024.
//

import SwiftUI

extension PostEditorView {
    var minTextEditorHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .title2).lineHeight * 4 + 15
    }
    
    var canDismiss: Bool { titleIsEmpty && contentIsEmpty && targets.count == 1 }
    
    var canSubmit: Bool {
        !titleIsEmpty && targets.allSatisfy { $0.community != nil && $0.resolutionState == .success }
    }
}
