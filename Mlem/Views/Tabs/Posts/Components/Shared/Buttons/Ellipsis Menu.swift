//
//  Ellipsis Menu.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-19.
//

import SwiftUI

struct EllipsisMenu: View {
    let size: CGFloat
    let shareUrl: String
    let deleteButtonCallback: (() async -> Void)?
    
    // bindings
    @State private var isPresentingConfirmDelete: Bool = false
    
    var body: some View {
        Menu {
            if let url = URL(string: shareUrl) {
                Button("Share") { showShareSheet(URLtoShare: url) }
            }
            Button(role: .destructive) {
                isPresentingConfirmDelete = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete")
                }
            }.disabled(deleteButtonCallback == nil)
            
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: size, height: size)
                .foregroundColor(.primary)
                .background(RoundedRectangle(cornerRadius: 4)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(.clear))
        }
        .onTapGesture { } // allows menu to pop up on first tap
        .confirmationDialog("Confirm delete", isPresented: $isPresentingConfirmDelete) {
            Button("Yes", role: .destructive) {
                Task {
                    if let deleteCallback = deleteButtonCallback {
                        await deleteCallback()
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete?  You cannot undo this action.")
        }
        
    }
}
