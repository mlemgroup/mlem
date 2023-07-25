//
//  Editor Tracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-21.
//
import Foundation

class EditorTracker: ObservableObject {
    @Published var editingResponse: ConcreteEditorModel?
    @Published var editPost: PostEditorModel?

    func openEditor(with editingResponse: ConcreteEditorModel) {
        self.editingResponse = editingResponse
    }
    
    func openEditor(with editPost: PostEditorModel) {
        self.editPost = editPost
    }
}
