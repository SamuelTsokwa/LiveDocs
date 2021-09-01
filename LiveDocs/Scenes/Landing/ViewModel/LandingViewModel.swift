//
//  LandingViewModel.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import UIKit
import Firebase
import FirebaseAuth
import Combine


class LandingViewModel: ObservableObject, Identifiable {

    private unowned let coordinator: LandingCoordinator
    var cancelBag = Set<AnyCancellable>()
    let db = Firestore.firestore()
    @Published var showSignup = false
    @Published var showLogin = false
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    @Published var signupPassword = ""
    @Published var signupEmail = ""
    @Published var isLoading = false
    @Published var showVeil = true
    @Published var displayName = ""
    
    
    init(coordinator: LandingCoordinator) {
        self.coordinator = coordinator
        signupEmail = "test\(UUID().uuidString)@yahoo.com"
        signupPassword = "qwerty1234!"
    }
    
    func didAppear() {
//        try! Auth.auth().signOut()
        
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.toHome()
                
            }
            
        } else {
            showVeil = false
        }
    }
    
    func didClickLogin() {
        showLogin.toggle()
    }
    
    func didClickSignup() {
        showSignup.toggle()
    }

    func hideAllModals() {
        showSignup = false
        showLogin = false
    }
    
    func firebaseLogin(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if error == nil {
                self?.isLoading = false
                self?.getCurrentUser(completion: nil)
                self?.toHome()
            }
        }
    }
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
    func login() {
        UIApplication.resignFirstResponder()
        showLogin = false
        isLoading = true
        firebaseLogin(email: loginEmail, password: loginPassword)
    }
    
    func signup() {
        let randomAnimals = ["Dog", "Cat", "Dino", "Fox", "Panda"]
        UIApplication.resignFirstResponder()
        showSignup = false
        isLoading = true
        Auth.auth().createUser(withEmail: signupEmail, password: signupPassword) { [weak self] authResult, error in
            if error != nil {
                
            }
            
            
            guard let result = authResult else {return}
            let id = "\(result.user.uid)"
            let createdAt = Timestamp(date: Date())
            
            guard var displayName = self?.displayName else {return}
            
            if displayName.isEmpty {
                displayName = "\(randomAnimals.randomElement() ?? "")" + "-\(self?.random(digits: 8) ?? "")"
            }
            
            let docData: [String: Any] = [
                "id": id,
                "createdAt": createdAt,
                "displayName": displayName
            ]
            
            self?.db.collection(Endpoints.USER_ENDPOINT).document(id).setData(docData) {  err in
                if error != nil {
                    
                }
                
//                CurrentUser.shared.currentUser = User(id: id, createdAt: createdAt.dateValue(), displayName: displayName)
                
                self?.firebaseLogin(email: self?.signupEmail ?? "", password: self?.signupPassword ?? "")
            }
        }

    }
}

extension LandingViewModel {
    func getCurrentUser(completion: (() -> ())? = nil) {
        let auth = Auth.auth()
        guard let uid = auth.currentUser?.uid else { return }
        
        let docRef = db.collection("Users").document(uid)
        
        docRef.getDocument { (document, error) in
            let result = Result {
              try document?.data(as: User.self)
            }
            switch result {
            case .success(let user):
                if let user = user {
                    // A `City` value was successfully initialized from the DocumentSnapshot.
                    CurrentUser.shared.currentUser = User(id: uid, createdAt: user.createdAt, displayName: user.displayName)
                } else {
                    // A nil value was successfully initialized from the DocumentSnapshot,
                    // or the DocumentSnapshot was nil.
                    print("Document does not exist")
                }
            case .failure(let error):
                // A `City` value could not be initialized from the DocumentSnapshot.
                print("Error decoding city: \(error)")
            }
        }
    }
    
    func toHome() {
        coordinator.toHome()
    }
}

