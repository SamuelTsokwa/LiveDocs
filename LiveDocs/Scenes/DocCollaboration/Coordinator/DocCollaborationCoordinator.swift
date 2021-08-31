//
//  DocCollaborationCoordinator.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import Foundation
import Combine

class DocCollaborationCoordinator: ObservableObject, Identifiable {

    @Published var viewModel: DocCollaborationViewModel!
    let documentState: DocumentState

    
    
    init(documentState: DocumentState) {
        self.documentState = documentState
        self.viewModel = DocCollaborationViewModel(coordinator: self, documentState: documentState)
    }

}
