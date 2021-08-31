//
//  RootViewModel.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import UIKit

class RootViewModel: ObservableObject, Identifiable {

    private unowned let coordinator: RootCoordinator
    
    init(coordinator: RootCoordinator)
    {
        self.coordinator = coordinator
    }

}

