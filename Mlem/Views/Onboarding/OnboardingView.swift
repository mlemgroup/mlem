//
//  OnboardingView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-15.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    enum OnboardingTab {
        case about, instances
    }
    
    @Binding var navigationPath: NavigationPath
    
    @State var selectedTab: OnboardingTab = .about
    @State var hideNav: Bool = true
    
    @State var selectedInstance: InstanceMetadata?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            aboutTab
                .tag(OnboardingTab.about)
            
            instancesTab
                .tag(OnboardingTab.instances)
        }
        .onChange(of: selectedInstance) { instance in
            guard let instanceUrl = instance?.url else { return }
            navigationPath.append(OnboardingRoute.login(instanceUrl))
        }
        .animation(.spring(response: 0.5), value: selectedTab)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    // MARK: - About Tab
    
    @ViewBuilder
    var aboutTab: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text(.init(whatIsLemmy))
                    .padding()
                
                VStack(spacing: 0) {
                    Divider()
                    
                    CollapsibleTextItem(
                        titleText: "About Lemmy",
                        bodyText: aboutLemmy
                    )
                    .padding(.horizontal)
                    
                    Divider()
                    
                    CollapsibleTextItem(
                        titleText: "About Instances and Federation",
                        bodyText: aboutInstances
                    )
                    .padding(.horizontal)
                    
                    Divider()
                }
                
                Spacer()
                
                onboardingNextButton
                    .padding()
                
                // add a little space for the tab selection indicator
                Spacer()
                    .frame(height: 36)
            }
        }
        .navigationTitle("What is Lemmy?")
    }
    
    @ViewBuilder
    var onboardingNextButton: some View {
        Button {
            selectedTab = .instances
        } label: {
            Text("Next")
                .padding(5)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
    
    // MARK: - Instances Tab
    
    var instancesTab: some View {
        InstancePickerView(selectedInstance: $selectedInstance, onboarding: true)
            .padding(.bottom, 36)
    }
}
