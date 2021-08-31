//
//  RootCoordinatorView.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import SwiftUI
import Foundation
import Combine
import SwiftUIKit

struct RootCoordinatorView: View {

    @ObservedObject var coordinator: RootCoordinator
    
    var body: some View {
        LandingCoordinatorView(coordinator: coordinator.landingCoordinator)
    }

}
