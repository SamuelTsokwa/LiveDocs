//
//  LandingCoordinator.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import Foundation
import SwiftUI
import Combine

class LandingCoordinator: ObservableObject, Identifiable {

    @Published var viewModel: LandingViewModel!
    @Published var homeCoordinator: HomeCoordinator!
    @ObservedObject var documentState: DocumentState = DocumentState()
    
    
    init() {
        self.viewModel = LandingViewModel(coordinator: self)
    }
    
    func toHome() {
        homeCoordinator = HomeCoordinator(documentState: documentState)
    }

}
