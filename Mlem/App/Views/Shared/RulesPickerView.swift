//
//  RulesPickerView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-11-11.
//

import MlemMiddleware
import SwiftUI

struct RulesPickerView: View {
    @Environment(\.dismiss) var dismiss
    
    let model: any ProfileProviding
    let callback: (String) -> Void
    
    var body: some View {
        Form {
            RulesListView(model: model, reason: .init(get: { "" }, set: {
                callback($0)
                dismiss()
            }))
        }
    }
}
