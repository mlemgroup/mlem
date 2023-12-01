//
//  MatrixLinkView.swift
//  Mlem
//
//  Created by Sjmarf on 30/11/2023.
//

import SwiftUI

struct MatrixLinkView: View {
    
    @State var matrixUser: String = ""
    
    var body: some View {
        Form {
            Section {
                VStack {
                    Image("logo.matrix")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                        
                    Text("Link Matrix Account")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color(.systemGroupedBackground))
                
            }
            Section {
                TextField(text: $matrixUser) {
                    Text("@user:example.com")
                }
            }
            Section {
                Button("Save") {
                    
                }
                .frame(maxWidth: .infinity)
            } footer: {
                // swiftlint:disable:next line_length
                Text("Everyone will be able to see your username, and will be able to send you messages through Lemmy or another matrix client.")
            }
            Link("What is matrix?", destination: URL(string: "https://matrix.org/")!)
        }
    }
}
