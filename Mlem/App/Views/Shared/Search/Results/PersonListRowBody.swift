//
//  PersonListRowBody.swift
//  Mlem
//
//  Created by Sjmarf on 28/06/2024.
//

import MlemMiddleware
import SwiftUI

struct PersonListRowBody<Content: View>: View {
    enum Complication { case instance, date }
    
    let person: any Person
    let communityContext: (any Community)?
    let complications: [Complication]
    var showBlockStatus: Bool = true
    
    @ViewBuilder let content: () -> Content
    
    var title: String {
        if person.blocked, showBlockStatus {
            return "\(person.displayName) ∙ Blocked"
        } else {
            return person.displayName
        }
    }
    
    var body: some View {
        HStack(spacing: AppConstants.standardSpacing) {
            if person.blocked, showBlockStatus {
                Image(systemName: Icons.hide)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(9)
            } else {
                AvatarView(person)
                    .frame(height: 46)
            }
            let flairs = person.getFlairs(communityContext: communityContext)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(flairs, id: \.self) { flair in
                        Image(systemName: flair.icon)
                            .imageScale(.small)
                            .foregroundStyle(flair.color)
                    }
                    Text(title)
                        .lineLimit(1)
                }
                caption
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            content()
        }
        padding(.horizontal)
            .contentShape(Rectangle())
    }
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter
    }
    
    @ViewBuilder
    var caption: some View {
        HStack(spacing: 2) {
            ForEach(Array(complications.enumerated()), id: \.element) { index, complication in
                if index != 0 {
                    Text("∙")
                }
                Group {
                    switch complication {
                    case .instance:
                        if let host = person.host {
                            Text("@\(host)")
                        }
                    case .date:
                        Text(dateFormatter.string(from: person.created))
                    }
                }
            }
        }
    }
}
