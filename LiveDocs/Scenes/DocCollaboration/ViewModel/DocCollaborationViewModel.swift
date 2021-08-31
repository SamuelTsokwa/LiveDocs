//
//  DocCollaborationViewModel.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import Combine
import SwiftUI
import Firebase
import UIKit

class DocCollaborationViewModel: ObservableObject, Identifiable {

    private unowned let coordinator: DocCollaborationCoordinator
    let documentState: DocumentState
    var textView: UITextView
    var scrollView: UIScrollView
    var collaboratorListener: ListenerRegistration?
    var mainListener: ListenerRegistration?
    let db = Firestore.firestore()
    @Published var showSaved = false
    @Published var liveMode = true
    @Published var showCopied = false
    @Published var docText: NSMutableAttributedString
    @Published var range: NSRange = NSRange()
    @Published var defaultFont: UIFont = UIFont(name: "TimesNewRomanPSMT", size: 16) ?? .systemFont(ofSize: 16)
    @Published var defaultColor: UIColor = .white
    @Published var allFonts: [String] = []
    @Published var userColors: [Color] = [.green, .blue, .pink, .purple]
    @Published var collaborators = [String: User]()
    @Published var collaboratorsColors = [String: Color]()
    @Published var collaboratorsPositions = [String: (CGFloat, CGFloat, CGFloat, CGFloat)]()
    
    // text color Attributes
    @Published var textColor: Color = .white
    @Published var highlightedColor: Color = .white
    
    // text font Attributes
    @Published var font: UIFont = UIFont(name: "TimesNewRomanPSMT", size: 16) ?? .systemFont(ofSize: 16)
    @Published var highlightedFont: UIFont = UIFont(name: "TimesNewRomanPSMT", size: 16) ?? .systemFont(ofSize: 16)
    
    // text font Attributes
    @Published var fontSize: CGFloat = 16
    @Published var highlightedFontSize: CGFloat = 16
    
    // text font Attributes
    @Published var lineSpacing: CGFloat = 4
    @Published var highlightedlineSpacing: CGFloat = 4
    
    init(coordinator: DocCollaborationCoordinator, documentState: DocumentState) {
        
        self.coordinator = coordinator
        self.documentState = documentState
        docText = documentState.currentDocument.content
        
        textView = UITextView()
        scrollView = UIScrollView()
        
        intialSetup()
        
    }
    
    func intialSetup() {
        
        // move this
        allFonts = CurrentUser.shared.allFonts
        
        
        if !documentState.currentDocument.saved {
            docText.addAttribute(.foregroundColor, value: defaultColor, range: NSRange(location: 0, length: docText.length ))
            docText.addAttribute(.font, value: defaultFont, range: NSRange(location: 0, length: docText.length ))
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 4
            docText.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: docText.length ))
        }
        
        
                
        startListener()

    }
    
    func applyAttribute(attributeType: AttributeType) {
        switch attributeType {
            case .font:
                applyFont()
            case .fontSize:
                applyFontSize()
            case .textColor:
                applyTextColor()
            case .highlightColor:
                applyHighlightColor()
            case .bold:
                applyBold()
            case .italics:
                applyItalics()
            case .underline:
                applyUnderline()
        }
    }
    
    func applyTextColor() {
        
        if range.length != 0 {
            let newAttribute = docText
            newAttribute.addAttribute(.foregroundColor, value: UIColor(highlightedColor), range: range)
            docText = newAttribute
        }
        
        textView.textColor = UIColor(textColor)
        
    }
    
    func applyFont() {
        if range.length != 0 {
            let newAttribute = docText
            newAttribute.addAttribute(.font, value: highlightedFont, range: range)
            docText = newAttribute
        }
        
        textView.font = font
        
    }
    
    func applyFontSize() {
        
        if range.length != 0 {
            let newAttribute = docText
            guard let newFont = UIFont(name: highlightedFont.fontName, size: highlightedFontSize) else { return }
            newAttribute.addAttribute(.font, value: newFont, range: range)
            docText = newAttribute
        }
        
        guard let newFont = UIFont(name: font.fontName, size: fontSize) else { return }
        textView.font = newFont
    }
    
    func applyHighlightColor() {
        docText.addAttribute(.foregroundColor, value: textColor, range: range)
    }
    
    func applyBold() {
        docText.addAttribute(.foregroundColor, value: textColor, range: range)
    }
    
    func applyItalics() {
        docText.addAttribute(.foregroundColor, value: textColor, range: range)
    }
    
    func applyUnderline() {
        docText.addAttribute(.foregroundColor, value: textColor, range: range)
    }
    
    func getHighlightedTextColor() {

        docText.enumerateAttribute(.foregroundColor , in: range, options: [.longestEffectiveRangeNotRequired]) { value, range, isStop in
            if let value = value {
                guard let color = (value as? UIColor) else { return }
                highlightedColor = color.color
            }
        }
    }
    
    func getHighlightedTextFont() {

        docText.enumerateAttribute(.font , in: range, options: [.longestEffectiveRangeNotRequired]) { value, range, isStop in
            if let value = value {
                guard let font = (value as? UIFont) else { return }
                highlightedFont = font
            }
        }
    }
    
    func saveText() {
        
        let archivedData: Data = try! NSKeyedArchiver.archivedData(withRootObject: docText, requiringSecureCoding: false)
        
        let data: [String : Any] = ["saved": true, "id": documentState.currentDocument.id, "author": documentState.currentDocument.author, "createdAt": documentState.currentDocument.createdAt, "title": documentState.currentDocument.title, "content": archivedData, "createdBy": documentState.currentDocument.createdBy]
        
        let path = db.collection(Endpoints.DOCUMENT_ENDPOINT).document(documentState.currentDocument.createdBy)
            
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
            .document(documentState.currentDocument.id)
            .setData(data, merge: true)
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                }
                else {
                    self.showSaved = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.showSaved = false
                    }
                    
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
    
    func createSharableCode() {
        let code = "novadocs://base?doc=\(CurrentUser.shared.currentUser.id)&id=\(documentState.currentDocument.id)"
        UIPasteboard.general.string = code
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showCopied = false
        }
    }
    
    func didAppear() {
        

        let collaborators : [String:Any] = [
            "id": CurrentUser.shared.currentUser.id,
            "displayName": CurrentUser.shared.currentUser.displayName,
            "createdAt": CurrentUser.shared.currentUser.createdAt,
            "online": true
        ]
        
        
        db.collection(Endpoints.DOCUMENT_ENDPOINT).document(documentState.currentDocument.createdBy)
            .collection(Endpoints.DOCUMENT_ENDPOINT)
            .document(documentState.currentDocument.id)
            .collection("collaborators")
            .document(CurrentUser.shared.currentUser.id)
            .setData(collaborators, merge: true)
            
    }
    
    func didDisappear() {
        let collaborators : [String:Any] = [
            "id": CurrentUser.shared.currentUser.id,
            "displayName": CurrentUser.shared.currentUser.displayName,
            "createdAt": CurrentUser.shared.currentUser.createdAt,
            "online": false
        ]
        
        
        db.collection(Endpoints.DOCUMENT_ENDPOINT).document(documentState.currentDocument.createdBy)
            .collection(Endpoints.DOCUMENT_ENDPOINT)
            .document(documentState.currentDocument.id)
            .collection("collaborators")
            .document(CurrentUser.shared.currentUser.id)
            .setData(collaborators, merge: true)
    }
    
    func startListener() {
        collaboratorListener = collaboratorListenerFunction()
        mainListener = mainListenerFunction()
    }
    
    func stopListener() {
        collaboratorListener?.remove()
        mainListener?.remove()
    }
    
    func restartListener() {
        collaboratorListener = collaboratorListenerFunction()
        mainListener = mainListenerFunction()
    }
    
    func mainListenerFunction() -> ListenerRegistration{
       return db.collection(Endpoints.DOCUMENT_ENDPOINT).document(documentState.currentDocument.createdBy)
            .collection(Endpoints.DOCUMENT_ENDPOINT)
            .document(documentState.currentDocument.id)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let document = snapshot else {return}
                guard let data = document.data() else {return}
                
                if let content = data["content"] as? Data {
                    guard let unarchivedData: NSMutableAttributedString  = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(content) as? NSMutableAttributedString else {return}
                    self?.docText = unarchivedData
                    self?.documentState.currentDocument.content = unarchivedData
                }
            }
    }
    
    func collaboratorListenerFunction() -> ListenerRegistration {
        return db.collection(Endpoints.DOCUMENT_ENDPOINT).document(documentState.currentDocument.createdBy)
            .collection(Endpoints.DOCUMENT_ENDPOINT)
            .document(documentState.currentDocument.id)
            .collection("collaborators")
            .addSnapshotListener({ [weak self] snapshot, error in
                guard let document = snapshot else {
                    return
                }
                
                for document in document.documents {
                    let doc = document.data()
                    
                    if let id = doc["id"] as? String, let displayName = doc["displayName"] as? String, let createdAt = doc["createdAt"] as? Timestamp, let online =  doc["online"] as? Bool{

                        let newCollaborator = User(id: id, createdAt: createdAt.dateValue(), displayName: displayName, online: online)

                        guard let count = self?.collaborators.count else { return }

                        if count <= 4 {
                            if newCollaborator.id != CurrentUser.shared.currentUser.id {

                                if self?.collaboratorsColors[id] == nil {
                                    self?.collaboratorsColors[id] = Color.random
                                }
                            } else {
                                self?.collaboratorsColors[id] = .white
                            }

                            self?.collaborators[id] = newCollaborator

                        }
                        
                        if let x = doc["x"] as? CGFloat, let y = doc["y"] as? CGFloat, let height = doc["height"] as? CGFloat, let width = doc["width"] as? CGFloat {

                            let cursorRect = CGRect(x: x, y: y, width: width, height: height)
                            guard let converted = self?.textView.convert(cursorRect, to: self?.scrollView) else {return}
                            self?.collaboratorsPositions[newCollaborator.id] = (converted.origin.x, converted.origin.y, converted.width,converted.height)
//                                (converted.x,converted.y,converted.width,converted.height)
                        }



                    }
                    
                    

                }

            })
    }
    
    
    
    func didEndTyping(cursor: CGRect) {
        
        if liveMode {
            
            let archivedData: Data = try! NSKeyedArchiver.archivedData(withRootObject: docText, requiringSecureCoding: false)
            
            let data: [String : Any] = ["content": archivedData, "lastEditedBy": CurrentUser.shared.currentUser.id]
            
            db.collection(Endpoints.DOCUMENT_ENDPOINT).document(documentState.currentDocument.createdBy)
                .collection(Endpoints.DOCUMENT_ENDPOINT)
                .document(documentState.currentDocument.id)
                .updateData(data)
            
            
//            let position : [String:Any] = [
//                "x": cursor.origin.x,
//                "y": cursor.origin.y,
//                "width": cursor.width,
//                "height": cursor.height,
//            ]
//
//
//            db.collection(Endpoints.DOCUMENT_ENDPOINT).document(documentState.currentDocument.createdBy)
//                .collection(Endpoints.DOCUMENT_ENDPOINT)
//                .document(documentState.currentDocument.id)
//                .collection("collaborators")
//                .document(CurrentUser.shared.currentUser.id)
//                .setData(position, merge: true)
        }
    }


}


enum AttributeType: CaseIterable {
    case font
    case fontSize
    case textColor
    case highlightColor
    case bold
    case italics
    case underline
}

extension AttributeType {
    var attributeDisplayName: String {
        switch self {
            case .font:
                return "Font"
            case .fontSize:
                return "Size"
            case .textColor:
                return "Text Color"
            case .highlightColor:
                return "Highlight"
            case .bold:
                return "Bold"
            case .italics:
                return  "Italics"
            case .underline:
                return "Underline"
        }
        
    }
    
    var attributeImageName: String {
        switch self {
            case .font:
                return "font"
            case .fontSize:
                return "size"
            case .textColor:
                return "textColor"
            case .highlightColor:
                return "highlight"
            case .bold:
                return "bold"
            case .italics:
                return  "italics"
            case .underline:
                return "underline"
        }
    }
}
