//
//  PersonListRow.swift
//  Mlem
//
//  Created by Sjmarf on 06/07/2024.
//

import MlemMiddleware
import SwiftUI

struct PersonListRow<Content2: View>: View {
    typealias Content = PersonListRowBody<Content2>
    
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    
    let person: any Person
    let content: Content

    init(
        _ person: any Person,
        complications: [Content.Complication] = [.instance],
        showBlockStatus: Bool = true,
        @ViewBuilder content: @escaping () -> Content2
    ) {
        self.person = person
        self.content = .init(person, complications: complications, showBlockStatus: showBlockStatus, content: content)
    }
    
    init(
        _ person: any Person,
        complications: [Content.Complication] = [.instance],
        showBlockStatus: Bool = true,
        readout: Content.Readout? = nil
    ) where Content2 == EmptyView {
        self.person = person
        self.content = .init(person, complications: complications, showBlockStatus: showBlockStatus, readout: readout)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            content
            Image(systemName: Icons.forward)
                .imageScale(.small)
                .foregroundStyle(palette.tertiary)
        }
        .padding(.trailing)
        .padding(.vertical, 6)
        .onTapGesture {
            navigation.push(.person(person))
        }
        .background(palette.background)
        .contextMenu(actions: person.menuActions(navigation: navigation))
    }
}
