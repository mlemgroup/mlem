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
    @Environment(\.communityContext) var communityContext
    
    let person: any Person
    let content: Content
    let visitContext: VisitHistory.VisitContext

    init(
        _ person: any Person,
        complications: [Content.Complication] = [.instance],
        showBlockStatus: Bool = true,
        visitContext: VisitHistory.VisitContext = .other,
        @ViewBuilder content: @escaping () -> Content2
    ) {
        self.person = person
        self.content = .init(person, complications: complications, showBlockStatus: showBlockStatus, content: content)
        self.visitContext = visitContext
    }
    
    init(
        _ person: any Person,
        complications: [Content.Complication] = [.instance],
        showBlockStatus: Bool = true,
        readout: Content.Readout? = nil,
        visitContext: VisitHistory.VisitContext = .other
    ) where Content2 == EmptyView {
        self.person = person
        self.content = .init(person, complications: complications, showBlockStatus: showBlockStatus, readout: readout)
        self.visitContext = visitContext
    }
    
    var body: some View {
        Button {
            navigation.push(.person(person, visitContext: visitContext))
        } label: {
            FormChevron { content }
                .padding(.trailing)
        }
        .buttonStyle(.empty)
        .padding(.vertical, 6)
        .background(palette.secondaryGroupedBackground, in: .rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu { person.menuActions(navigation: navigation, community: communityContext) }
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
}

#if DEBUG
    #Preview(traits: .sampleEnvironment) {
        ScrollView {
            ForEach(PersonMockType.Realistic.allCases) { type in
                PersonListRow(
                    Person2.mock(.realistic(type)),
                    complications: [.instance, .date],
                    readout: .postsAndComments
                )
            }
        }
        .contentMargins(.horizontal, Constants.main.standardSpacing)
        .background(Palette.main.groupedBackground)
    }
#endif
