//
//  Instance Summary.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-17.
//

import Foundation
import SwiftUI

struct InstanceSummary: View {
    
    let instance: InstanceMetadata
    
    @State var isCollapsed: Bool = true
    // @StateObject var instanceDetails: APISiteView
    
    var rotation: Angle { Angle(degrees: isCollapsed ? 0.0 : 90.0) }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 1)) {
                self.isCollapsed.toggle()
            }
        } label: {
            VStack {
                collapsibleHeader
                
                if !isCollapsed {
                    instanceDetails
                        .onAppear {
                            print(instance.name)
                        }
                }
            }
            .padding()
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var collapsibleHeader: some View {
        HStack {
            Text(instance.name)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .rotationEffect(rotation)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var instanceDetails: some View {
        Text(instance.url.description)
            .padding(.top, 5)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func fetchInstanceDetails() async {
        
    }
}
