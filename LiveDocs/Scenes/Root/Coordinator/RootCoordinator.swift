//
//  RootCoordinator.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import Foundation
import Combine


class RootCoordinator: ObservableObject, Identifiable {

    @Published var viewModel: RootViewModel!
    
    @Published var tab: CoordinatorTab = .one
    @Published var landingCoordinator: LandingCoordinator
    
    
    init() {
        self.landingCoordinator = LandingCoordinator()
        self.viewModel = RootViewModel(coordinator: self)
        
    }

}
