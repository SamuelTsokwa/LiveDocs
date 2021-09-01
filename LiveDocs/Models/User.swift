//
//  User.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import Foundation
import Firebase
import UIKit
import Combine

struct User: Identifiable, Codable {
    var id: String
    var createdAt: Date
    var displayName: String
    var online: Bool?
    var position: [String]?
}

class CurrentUser: ObservableObject {
    static let shared = CurrentUser()
    var currentUser: User = User(id: "", createdAt: Date(), displayName: "")
    var allFonts = [String]()
    
    private init() {
        UIFont.familyNames.forEach { name in
            UIFont.fontNames(forFamilyName: name).forEach { font in
                allFonts.append(font)
            }
        }
    }
}
