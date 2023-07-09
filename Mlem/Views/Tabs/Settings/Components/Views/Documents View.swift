//
//  Documents View.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-09.
//

import Foundation
import SwiftUI

struct DocumentsView: View {
    @State var presentedDocument: Document?
    
    var body: some View {
        VStack(alignment: .labelStart) {
            List {
                Button {
                    presentedDocument = privacyPolicy
                } label: {
                    Label {
                        Text("Privacy Policy")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "binoculars.fill")
                            .foregroundColor(.purple)
                    }
                }
                
                Button {
                    presentedDocument = eula
                } label: {
                    Label {
                        Text("EULA")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "doc.plaintext.fill")
                            .foregroundColor(.purple)
                    }
                }
            }
        }
        .sheet(item: $presentedDocument) { presentedDocument in
            documentView(doc: presentedDocument)
        }
        .navigationTitle("Documents")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func documentView(doc: Document) -> some View {
        ScrollView {
            MarkdownView(text: doc.body, isNsfw: false)
        }
        .padding()
    }
    
}
