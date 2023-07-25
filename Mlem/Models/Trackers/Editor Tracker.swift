//
//  Editor Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//
import Foundation

class EditorTracker: ObservableObject {
    @Published var editing: ConcreteEditorModel?

    func openEditor(with editorModel: ConcreteEditorModel) {
        editing = editorModel
    }
}
