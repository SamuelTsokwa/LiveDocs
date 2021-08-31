//
//  LandingCoordinatorView.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import SwiftUI
import Foundation
import Combine
import SwiftUIKit

struct LandingCoordinatorView: View {

    @ObservedObject var coordinator: LandingCoordinator
    
    var body: some View {
        LandingView(viewModel: coordinator.viewModel)
            .statusBarStyle(.lightContent)
            .fullScreen(item: $coordinator.homeCoordinator){
                homeCoordinator  in
                HomeCoordinatorView(coordinator: homeCoordinator)
            }
    }

}
