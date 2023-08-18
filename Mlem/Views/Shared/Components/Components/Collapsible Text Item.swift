//
//  Collapsible Text Item.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-15.
//

import Foundation
import SwiftUI

struct CollapsibleTextItem: View {
    let titleText: String
    let bodyText: String
    
    @State var isCollapsed: Bool = true
    
    var rotation: Angle { Angle(degrees: isCollapsed ? 0.0 : 90.0) }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 1)) {
                self.isCollapsed.toggle()
            }
        } label: {
            VStack {
                HStack {
                    Text(titleText)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(rotation)
                }
                .frame(maxWidth: .infinity)
                
                if !isCollapsed {
                    Text(bodyText)
                        .padding(.top, 5)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
