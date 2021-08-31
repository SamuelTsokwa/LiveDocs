//
//  RootView.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import SwiftUI
import Foundation
import Combine
import SwiftUIKit

struct RootView: View {

    @ObservedObject var viewModel : RootViewModel
    
    var body: some View {
        Text("View")
    }

}
