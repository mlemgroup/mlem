//
//  Search Field.swift
//  Mlem
//
//  Created by David Bureš on 05.04.2022.
//

import SwiftUI

struct SearchField: View
{
    @State private var searchContent: String = ""

    @State private var isEditing: Bool = false

    var body: some View
    {
        HStack
        {
            TextField("Go to community...", text: $searchContent)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                .overlay(
                    HStack
                    {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if isEditing
                        {
                            Button(action: {
                                self.searchContent = ""
                            })
                            {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )

            if isEditing
            {
                Button(action: {
                    self.isEditing = false
                    self.searchContent = ""

                })
                {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}
