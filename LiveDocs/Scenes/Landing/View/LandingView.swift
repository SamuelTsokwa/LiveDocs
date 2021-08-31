//
//  LandingView.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import SwiftUI
import Foundation
import Combine
import SwiftUIKit

struct LandingView: View {

    @ObservedObject var viewModel : LandingViewModel
    
    var body: some View {
        ZStack {
            Color.darkBackgroundColor
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    viewModel.hideAllModals()
                }
            
            VStack(alignment: .center) {
                Image("document")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .padding(.horizontal)
                    .offset(y: -20)
                
                Text("LiveDocs")
                    .bold()
                
                Button {
                    viewModel.didClickLogin()
                } label: {
                    Text("Log in")
                        .bold()
                        .foregroundColor(.black)
                }
                .frame(height: 50)
                .padding(.horizontal, 50)
                .padding(.vertical)
                .buttonStyle(FilledButtonStyle(color: .white, cornerRadius: 25, padding: 15))
                
                Button {
                    viewModel.didClickSignup()
                } label: {
                    Text("Sign up")
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(height: 50)
                .padding(.horizontal, 50)
                .buttonStyle(FilledButtonStyle(color: .appAccent, cornerRadius: 25, padding: 15))
                
                
            }
            
            if viewModel.showVeil {
                ZStack {
                    Color.darkBackgroundColor
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Image("document")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .padding(.horizontal)
                            .offset(y: -20)
                        
                        Text("LiveDocs")
                            .bold()
                    }
                }
                
                .edgesIgnoringSafeArea(.all)
            }
            
            
            
        }
        .overlay(
            login
                .frame(height: 330)
                .edgesIgnoringSafeArea(.bottom)
            , alignment: .bottom)
        .overlay(
            signup
                .frame(height: 330)
                .edgesIgnoringSafeArea(.bottom)
            , alignment: .bottom)
        .loadingView(isAnimating: $viewModel.isLoading)
        .onAppear {
            viewModel.didAppear()
        }
        
        
        
    }

    var login: some View {
        ZStack {
            if viewModel.showLogin {
                ZStack {
                    Color.white
                        .edgesIgnoringSafeArea(.bottom)
                    
                    VStack {
                        TextfieldWithoutBorder(text: $viewModel.loginEmail, placeholder: "Email")
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(height: 50)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .padding(.top, 20)
                        
                        SecureTextfieldWithoutBorder(text: $viewModel.loginPassword, placeholder: "Password")
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(height: 50)
                            .padding(.horizontal, 20)
                        
                        Button {
                            viewModel.login()
                        } label: {
                            Text("Log in")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(height: 50)
                        .padding(.horizontal, 50)
                        .padding(.vertical)
                        .buttonStyle(FilledButtonStyle(color: .appAccent, cornerRadius: 25, padding: 15))
                    }
                }
                .transition(.opacity)
            }
            
        }
        
    }
    
    var signup: some View {
        ZStack {
            if viewModel.showSignup {
                ZStack {
                    Color.white
                        .edgesIgnoringSafeArea(.bottom)
                    VStack {
                        
                        TextfieldWithoutBorder(text: $viewModel.displayName, placeholder: "Display Name")
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(height: 50)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .padding(.top, 20)
                        
                        TextfieldWithoutBorder(text: $viewModel.signupEmail, placeholder: "Email")
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(height: 50)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .padding(.top, 20)
                        
                        SecureTextfieldWithoutBorder(text: $viewModel.signupPassword, placeholder: "Password")
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .frame(height: 50)
                            .padding(.horizontal, 20)
                        
                        Button {
                            viewModel.signup()
                        } label: {
                            Text("Sign up")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(height: 50)
                        .padding(.horizontal, 50)
                        .padding(.vertical)
                        .buttonStyle(FilledButtonStyle(color: .appAccent, cornerRadius: 25, padding: 15))
                    }
                }
                .transition(.opacity)
            }
        }
        
    }
}
