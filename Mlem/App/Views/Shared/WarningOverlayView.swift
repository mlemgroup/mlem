//
//  WarningOverlayView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-30.
//

import SwiftUI

struct WarningOverlayView: View {
    @Environment(Palette.self) private var palette
    @Environment(NavigationLayer.self) private var navigation
    
    let text: LocalizedStringResource
    @Binding var isPresented: Bool
    @Binding var showWarningAgain: Bool
    
    var body: some View {
        VStack(spacing: Constants.main.doubleSpacing) {
            WarningView(
                iconName: Icons.warning,
                text: text,
                inList: false
            )
            
            Group {
                HStack(spacing: Constants.main.doubleSpacing) {
                    Button {
                        navigation.pop()
                    } label: {
                        Text("Go back").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        isPresented = false
                    } label: {
                        Text("Continue").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Toggle(isOn: $showWarningAgain.invert(), label: {
                    Text("Don't show this again")
                })
            }
            .padding(.horizontal, 30)
        }
        .padding(Constants.main.doubleSpacing)
        .background {
            RoundedRectangle(cornerRadius: Constants.main.largeItemCornerRadius)
                .fill(palette.background.opacity(0.8))
        }
        .padding(Constants.main.doubleSpacing)
        .presentationBackground(.ultraThinMaterial)
    }
}
