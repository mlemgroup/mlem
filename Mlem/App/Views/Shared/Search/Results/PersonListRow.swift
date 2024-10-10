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
        Button {
            navigation.push(.person(person))
        } label: {
            FormChevron { content }
                .padding(.trailing)
        }
        .buttonStyle(.empty)
        .padding(.vertical, 6)
        .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu { person.menuActions(navigation: navigation) }
    }
}
