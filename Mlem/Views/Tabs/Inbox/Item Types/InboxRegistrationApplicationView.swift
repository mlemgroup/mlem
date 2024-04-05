//
//  InboxRegistrationApplicationView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-05.
//

import Dependencies
import Foundation
import SwiftUI

struct InboxRegistrationApplicationView: View {
    @EnvironmentObject var modToolTracker: ModToolTracker
    
    @ObservedObject var application: RegistrationApplicationModel
    
    var body: some View {
        VStack(spacing: 0) {
            InboxRegistrationApplicationBodyView(application: application)
            
            if !application.read {
                interactions
            }
        }
    }
    
    var interactions: some View {
        HStack(spacing: AppConstants.standardSpacing) {
            Button {
                modToolTracker.denyApplication(application)
            } label: {
                Text("Deny")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.red)
            .buttonStyle(.bordered)
            .clipShape(Capsule())
            
            Button {
                Task {
                    await application.approve()
                }
            } label: {
                Text("Approve")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Capsule())
        }
        .padding(.horizontal, AppConstants.standardSpacing)
        .padding(.bottom, AppConstants.standardSpacing)
    }
}
