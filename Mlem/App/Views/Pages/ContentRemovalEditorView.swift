//
//  ContentRemovalEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 09/10/2024.
//

import MlemMiddleware
import SwiftUI

struct ContentRemovalEditorView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    let target: any Interactable2Providing
    
    @State var community: any Community
    
    init(target: any Interactable2Providing) {
        self.target = target
        self._community = .init(wrappedValue: target.community)
    }

    var body: some View {
        ReasonPickerView(community: community, onSubmit: send)
    }
    
    func send(_ reason: String) async {
        switch await target.toggleRemoved(reason: reason).result.get() {
        case .succeeded:
            HapticManager.main.play(haptic: .success, priority: .low)
            dismiss()
        default:
            ToastModel.main.add(.failure())
        }
    }
}
