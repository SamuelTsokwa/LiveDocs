//
//  HomeCoordinator.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import Foundation
import Combine

class HomeCoordinator: ObservableObject, Identifiable {

    @Published var viewModel: HomeViewModel!
    @Published var docCollaborationCoordinator: DocCollaborationCoordinator!
    let documentState: DocumentState
    
    init(documentState: DocumentState) {
        self.documentState = documentState
        self.viewModel = HomeViewModel(coordinator: self, documentState: self.documentState)
    }

}

extension HomeCoordinator {
    func toDocCollaborationView() {
        self.docCollaborationCoordinator = DocCollaborationCoordinator(documentState: documentState)
    }
}
