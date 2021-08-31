//
//  DocCollaborationCoordinatorView.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import SwiftUI
import Foundation
import Combine
import SwiftUIKit

struct DocCollaborationCoordinatorView: View {

    @ObservedObject var coordinator: DocCollaborationCoordinator
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        DocCollaborationView(viewModel: coordinator.viewModel)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: { presentation.wrappedValue.dismiss() }) {
                HStack(alignment: .center , spacing: 10){
                    Image(systemName: "chevron.left")
                      .foregroundColor(.black)
                      .imageScale(.large)
                      .padding(.all, 5)
                      .background(Color.white)
                        .clipShape(Circle())

                    Spacer()
                }
            })
            .allowFullScreenOverlays()
    }

}
