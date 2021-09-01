//
//  HomeCoordinatorView.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import SwiftUI
import Foundation
import Combine
import SwiftUIKit

struct HomeCoordinatorView: View {

    @ObservedObject var coordinator: HomeCoordinator
//    @Environment(\.deeplink) var deeplink
    @EnvironmentObject var deeplink: Deeplinker
    
    var body: some View {
        NavigationView {
            HomeView(viewModel: coordinator.viewModel)
                .statusBarStyle(.lightContent)
                .navigation(item: $coordinator.docCollaborationCoordinator) {
                    docCollaborationCoordinator in
                    DocCollaborationCoordinatorView(coordinator: docCollaborationCoordinator)
                }
                .onChange(of: deeplink.deeplink, perform: { deeplink in
                    guard let deeplink = deeplink else { return }
                    switch deeplink {
                       
                        case .document(document: let document, id: let id):
                            coordinator.viewModel.handleDeepLink(document: document, id: id)
                        case .home:
                            break
                    }
                    
                 })
                
        }
    }

}


