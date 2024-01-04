//
//  FakeSection.swift
//  Mlem
//
//  Created by Sjmarf on 02/01/2024.
//

import SwiftUI

struct CollapsibleSection<Content: View>: View {
    var header: String?
    var footer: String?

    @ViewBuilder var content: () -> Content
    @State private var collapsed: Bool
  
    init(
        _ header: String? = nil,
        footer: String? = nil,
        collapsed: Bool = false,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = content
        self._collapsed = State(wrappedValue: collapsed)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let header {
                HStack {
                    Text(header)
                        .textCase(.uppercase)
                        .opacity(0.5)
                    Spacer()
                    Image(systemName: Icons.dropdown)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentColor)
                        .rotationEffect(Angle(degrees: collapsed ? -90 : 0))
                        .onTapGesture { withAnimation(.default) { collapsed.toggle() }}
                }
                .font(.footnote)
                .padding(.horizontal, 16)
            }
            
            if !collapsed {
                VStack(alignment: .leading, spacing: 8) {
                    VStack {
                        content()
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius))
                }
                
                if let footer = footer {
                    Text(footer)
                        .textCase(.uppercase)
                        .font(.footnote)
                        .padding(.horizontal, 16)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .clipped()
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
  }
}
