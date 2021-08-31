//
//  Document.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct Document: Identifiable, Equatable {
    static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let saved: Bool
    let author: String
    let createdBy: String
    let createdAt: Date
    let title: String
    var collaborators: [User]?
    var content: NSMutableAttributedString

}

class DocumentState: ObservableObject {
    @Published var currentDocument: Document = Document(id: UUID().uuidString, saved: false, author: "me", createdBy: "", createdAt: Date(), title: "", content: NSMutableAttributedString())
}

extension Document {
    var dateAsString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let fullDate = dateFormatter.string(from: self.createdAt)
        return fullDate
    }
}
