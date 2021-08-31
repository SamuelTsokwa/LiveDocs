//
//  HomeViewModel.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import UIKit
import Firebase

class HomeViewModel: ObservableObject, Identifiable {

    private unowned let coordinator: HomeCoordinator
    let documentState: DocumentState
    let db = Firestore.firestore()
    @Published var myDocuments =  [String:Document]()
    @Published var sharedWithMe =  [String:Document]()
    @Published var newDocumentTitle = "untitled"
    @Published var newDocumentAuthor = ""
    @Published var isLoading = true
    @Published var showEmptyState = true
    
    
    init(coordinator: HomeCoordinator, documentState: DocumentState) {
        self.coordinator = coordinator
        self.documentState = documentState

        getCurrentUser {
            self.getDocuments()
        }
        


    }
    
    func getCurrentUser(completion: (() -> ())? = nil) {
        let auth = Auth.auth()
        guard let uid = auth.currentUser?.uid else { return }
        
        let docRef = db.collection("Users").document(uid)
        
        docRef.getDocument { [weak self] (document, error) in
            let result = Result {
                  try document?.data(as: User.self)
                }
            switch result {
                case .success(let user):
                    if let user = user {
                        // A `City` value was successfully initialized from the DocumentSnapshot.
                        CurrentUser.shared.currentUser = User(id: uid, createdAt: user.createdAt, displayName: user.displayName)
                        
                        if let completion = completion {
                            completion()
                        }
                        
                    } else {
                        // A nil value was successfully initialized from the DocumentSnapshot,
                        // or the DocumentSnapshot was nil.
                        print("Document does not exist")
                    }
                case .failure(let error):
                    // A `City` value could not be initialized from the DocumentSnapshot.
                    print("Error decoding city: \(error)")
            }
            self?.isLoading = false
        }
    }
    
    func handleDeepLink(document: String, id: String) {

        db.collection(Endpoints.DOCUMENT_ENDPOINT).document(document).collection(Endpoints.DOCUMENT_ENDPOINT).document(id)
            .getDocument { (document, error) in
            
                if let document = document, document.exists {
                    guard let data = document.data() else {return}
                    
                    if let id = data["id"] as? String, let createdBy =  data["createdBy"] as? String, let author =  data["author"] as? String, let saved =  data["saved"] as? Bool,let createdAt = data["createdAt"] as? Timestamp, let title = data["title"] as? String, let content = data["content"] as? Data  {
                        
                        guard let unarchivedData: NSMutableAttributedString  = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(content) as? NSMutableAttributedString else {return}
                        
                        let doc = Document(id: id, saved: saved, author: author, createdBy: createdBy, createdAt: createdAt.dateValue(), title: title, content: unarchivedData)
                        
                        self.toDocCollaborationView(doc)
                        
                        DispatchQueue.main.async {
                            self.addToSharedWithMe(doc: doc)
                        }
                    }
                    
                } else {
                    print("Document does not exist")
                }
        }
            
    }
    
    func addToSharedWithMe(doc: Document) {
        
        let archivedData: Data = try! NSKeyedArchiver.archivedData(withRootObject: doc.content, requiringSecureCoding: false)
        
        let data: [String : Any] = ["saved": true, "id": doc.id, "author": doc.author, "createdAt": doc.createdAt, "title": doc.title, "content": archivedData, "createdBy": doc.createdBy]
        
        let path = db.collection(Endpoints.DOCUMENT_ENDPOINT).document(CurrentUser.shared.currentUser.id)
            
        path.setData(["test" : ""])
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                }
                else {
                }
            }
        
        path
            .collection(Endpoints.DOCUMENT_ENDPOINT)
            .document(doc.id)
            .setData(data) {
                err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    path
                        .updateData(["test" : FieldValue.delete()])
                        { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                            }
                        }
                }
                
            }
    }
    
    func getDocuments() {
        
        newDocumentAuthor = CurrentUser.shared.currentUser.displayName
        
        db.collection(Endpoints.DOCUMENT_ENDPOINT).document(CurrentUser.shared.currentUser.id)
            .collection(Endpoints.DOCUMENT_ENDPOINT)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                for document in document.documents {
                    let data = document.data()

                    if let id = data["id"] as? String, let createdBy =  data["createdBy"] as? String,let author =  data["author"] as? String, let saved =  data["saved"] as? Bool,let createdAt = data["createdAt"] as? Timestamp, let title = data["title"] as? String, let content = data["content"] as? Data  {
                        
                        guard let unarchivedData: NSMutableAttributedString  = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(content) as? NSMutableAttributedString else {return}
                        
                        let doc = Document(id: id, saved: saved, author: author, createdBy: createdBy, createdAt: createdAt.dateValue(), title: title, content: unarchivedData)
                        
                        
                        if createdBy != CurrentUser.shared.currentUser.id {
                            
                            self?.sharedWithMe[doc.id] = doc
                        } else {
                            self?.myDocuments[doc.id] = doc
                        }
                        
                        
                        guard let sharedWithMe = self?.sharedWithMe else {return}
                        guard let myDocuments = self?.myDocuments else {return}

                        for (k,v) in Array(sharedWithMe).sorted(by: {$0.1.createdAt < $1.1.createdAt}) {
                            self?.sharedWithMe[k] = v
                        }
                        
                        for (k,v) in Array(myDocuments).sorted(by: {$0.1.createdAt < $1.1.createdAt}) {
                            self?.myDocuments[k] = v
                        }
                        
                        
                        
                        
                    }
                    
                    
                }
            
                self?.showEmptyState = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.isLoading = false
                }
               
            }
    }

}

extension HomeViewModel {
    func toDocCollaborationView(_ current: Document) {
        documentState.currentDocument = current
        self.coordinator.toDocCollaborationView()
    }
    
    func didClickCreateNew() {
        let newDoc = Document(id: UUID().uuidString, saved: false, author: newDocumentAuthor, createdBy: CurrentUser.shared.currentUser.id, createdAt: Date(), title: newDocumentTitle, content: NSMutableAttributedString())
        newDocumentTitle = "untitled"
        toDocCollaborationView(newDoc)
    }
}
