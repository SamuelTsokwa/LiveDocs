//
//  HomeView.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import SwiftUI
import Foundation
import Combine
import SwiftUIKit

struct HomeView: View {

    var items: [GridItem] = [GridItem(.flexible(), spacing: 80), GridItem(.flexible(), spacing: 80)]
    @ObservedObject var viewModel : HomeViewModel
    @State var showModal = false
    
    
    
    var body: some View {
        ZStack {
            ScrollView {
                ZStack {
                    
                    VStack(alignment: .leading) {
                        
                        if Array(viewModel.sharedWithMe.values).count != 0 && !viewModel.isLoading  {
                            Text("Shared with me")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.leading)
                                .padding(.vertical)
                            
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(Array(viewModel.sharedWithMe.values), id: \.id) { doc in
                                    SharedWithMe(document: doc)
                                        .padding(.horizontal)
                                        .onTapGesture {
                                            viewModel.toDocCollaborationView(doc)
                                        }
                                }
                            }
                            
                        }
                        .redacted(reason: viewModel.isLoading ? .placeholder : [])
                        .padding(.vertical)
                        
                        
                        
                        if Array(viewModel.myDocuments.values).count != 0 && !viewModel.isLoading  {
                            Text("My documents")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.leading)
                                .padding(.vertical)
                        }
                                                            
                        
                        
                        LazyVStack {
                            ForEach(Array(viewModel.myDocuments.values), id: \.id) { doc in
                                DocumentListItem(document: doc) {
                                    viewModel.toDocCollaborationView(doc)
                                } deleteAction: { doc in
                                    viewModel.deleteDoc(doc: doc)
                                } copyLinkAction: { doc in
                                    viewModel.createSharableCode(doc: doc)
                                } duplicateAction: { doc in
                                    viewModel.duplicateDoc(doc: doc)
                                } editTitleAction: { doc in
                                    viewModel.editDocumentName(doc: doc)
                                }
                                    .padding(.bottom)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                        .redacted(reason: viewModel.isLoading ? .placeholder : [])
                        
                        
                        
                        
                    }
                
                    
                }
                
                
            }
            .background(Color.darkBackgroundColor.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            
            if viewModel.myDocuments.count == 0 && Array(viewModel.sharedWithMe.values).count == 0 && !viewModel.showEmptyState {
                
                
                VStack(alignment: .center) {
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            
                            Image("essay")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .padding(.horizontal)
                                .offset(x: 10)
                            
                            Text("You don't have any documents")
                                .foregroundColor(.white)
                                .padding(.leading)
                                .padding(.vertical)
                        }
                        
                        
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showModal.toggle()
                    }, label: {
                        HStack {
                            Text("create")
                                .foregroundColor(.white)
                                .bold()
                            
                            Image("editor")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        }
                        .padding()
                        .background(
                            Capsule()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.appAccent, Color.red]), startPoint: .leading, endPoint: .trailing))
                        )
                        
                    })
                    .padding()
                    
                }
                
                
            }
        }
        .modal(modalConfiguration: ModalConfiguration(isPresenting: $viewModel.showEditNameModal, modalTitle: "Edit Title", backgroundColor: .darkBackgroundColor, exitButtonColor: .white)) {
            
            VStack {
                
                TextfieldWithoutBorder(text: $viewModel.newDocumentTitle, placeholder: "Title", textColor: .white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(height: 50)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                                
                
                Button {
                    
                    viewModel.showEditNameModal = false
                    viewModel.changeTitle()
                    
                    
                                        
                } label: {
                    Text("Change")
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(height: 50)
                .padding(.horizontal, 20)
                .padding(.vertical)
                .buttonStyle(FilledButtonStyle(color: .appAccent, cornerRadius: 25, padding: 15))
                
            }
            .padding(.vertical)
            
            
        }
        .modal(modalConfiguration: ModalConfiguration(isPresenting: $showModal, modalTitle: "New Document", backgroundColor: .darkBackgroundColor, exitButtonColor: .white)) {
            
            VStack {
                
                TextfieldWithoutBorder(text: $viewModel.newDocumentTitle, placeholder: "Title", textColor: .white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(height: 50)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                                
                
                Button {
                    showModal = false
                    viewModel.didClickCreateNew()
                                        
                } label: {
                    Text("Create")
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(height: 50)
                .padding(.horizontal, 20)
                .padding(.vertical)
                .buttonStyle(FilledButtonStyle(color: .appAccent, cornerRadius: 25, padding: 15))
                
            }
            .padding(.vertical)
            
            
        }
        
    }

}

struct DocumentListItem: View {
    let document: Document
    let action: () -> Void
    let deleteAction: (_ document: Document) -> Void
    let copyLinkAction: (_ document: Document) -> Void
    let duplicateAction: (_ document: Document) -> Void
    let editTitleAction: (_ document: Document) -> Void
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                HighlightTextView(text: document.content)
                    .frame(minWidth: 140, maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color.darkBackgroundColor)
                    .padding(.horizontal, 8)
                    .onTapGesture {
                        action()
                    }
                
                Divider()
                    .background(Color.gray)
                    .padding(.horizontal, 8)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Group {
                            Text(document.title)
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold, design: .default))
                            
                            Image("cloud")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 15, height: 15)
                        }
                        .onTapGesture {
                            action()
                        }
                        
                        
                        Spacer()
                       
                        Menu {
                            Button("Delete", action: {deleteAction(document)})
                            Button("Copy link", action: {copyLinkAction(document)})
                            Button("Duplicate", action: {duplicateAction(document)})
                            Button("Edit Title", action: {editTitleAction(document)})
                            
                        } label: {
                            Label(
                                title: { Text("") },
                                icon: { Image("options")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .frame(width: 30, height: 30)
                                })
                        }
                    }
                    
                    Group {
                        Text(document.author)
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .regular, design: .default))
                        
                        Text(document.dateAsString)
                            .foregroundColor(.gray)
                            .font(.system(size: 16, weight: .light, design: .default))
                    }.onTapGesture {
                        action()
                    }
                    
                    
                }
                .padding(.horizontal, 8)
                
            }
            .padding(.vertical, 8)
        }
        
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.darkModalColor)
        )
    }
   
}

struct SharedWithMe: View {
    let document: Document
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {

                HighlightTextView(text: document.content)
                    .frame(height: 100)
                    .frame(minWidth: 140, maxWidth: .infinity)
                    .background(Color.darkBackgroundColor)
                    .padding(.horizontal, 8)

                    
                Divider()
                    .background(Color.gray)
                    .padding(.horizontal, 8)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(document.title)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold, design: .default))
                        
                        Image("cloud")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 15, height: 15)
                    }
                    
                    Text(document.author)
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .regular, design: .default))
                    
                    Text(document.dateAsString)
                        .foregroundColor(.gray)
                        .font(.system(size: 10, weight: .light, design: .default))
                }
                .padding(.horizontal, 8)
            }
            .padding(.vertical, 8)
        }
        
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.darkModalColor)
        )
    }
}

