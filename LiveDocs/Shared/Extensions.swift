//
//  Extensions.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import Foundation
import Combine
import SwiftUI

class Deeplinker: ObservableObject {
    @Published var deeplink: Deeplinker.Deeplink?
    enum Deeplink: Equatable {
        case home
        case document(document: String, id: String)
    }
    
    func manage(url: URL) -> Deeplink? {

        
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let params = components.queryItems else {
                print("Invalid URL or album path missing")
                return .home
            }
        guard let document = params.first(where: { $0.name == "doc" })?.value else {
            print(" document missing")
            return .home
        }

        guard let identifier = params.first(where: { $0.name == "id" })?.value else {
            print(" id missing")
            return .home
        }
        
        
        return .document(document: document, id: identifier)
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

extension URL {
    static let appScheme = "novadocs"
    static let appDetailsPath = "doc="
    static let appReferenceQueryName = "id="
    static let appDetailsUrlFormat = "\(Self.appScheme)://base?\(Self.appDetailsPath)&\(Self.appReferenceQueryName)"
//    novadocs://base?doc=lcudAcZWZ8dtvcO7AUipI2QxITx2&id=527ED44A-5411-42C1-9FBF-8CC553460A42
}

struct DeeplinkKey: EnvironmentKey {
    static var defaultValue: Deeplinker.Deeplink? {
        return nil
    }
}
extension EnvironmentValues {
    var deeplink: Deeplinker.Deeplink? {
        get {
            self[DeeplinkKey]
        }
        set {
            self[DeeplinkKey] = newValue
        }
    }
}
