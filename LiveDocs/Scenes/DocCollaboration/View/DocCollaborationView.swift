//
//  DocCollaborationView.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//


import SwiftUI
import Foundation
import Combine
import SwiftUIKit
import Introspect

struct DocCollaborationView: View {

    @Environment(\.presentationMode) var presentation
    @ObservedObject var viewModel : DocCollaborationViewModel
    @ObservedObject private var keyboard = KeyboardResponder()
    @State private var height: CGFloat = .zero
    @State var constantKeyboardHeight: CGFloat = 0
    @State var textView: UITextView = UITextView()
    @State var scrollView: UIScrollView = UIScrollView()
    @State var showMenu = false
    @State var showEdit = true
    @State var showSettingView = false
    @State var showColorPicker = false
    @State var showHighlightColorPicker = false
    @State var showFontPicker = false
    @State var showLinkSetter = false
    @State var gridLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
   

    
    init(viewModel : DocCollaborationViewModel) {
        self.viewModel = viewModel
        UITextView.appearance().backgroundColor = .clear
    }
    
    
    var body: some View {
        ZStack {
            Color.darkBackgroundColor
                .edgesIgnoringSafeArea(.all)

            ScrollView(showsIndicators: false) {
                ScrollViewReader { scrollReader in
                    ZStack {
                        TextView(height: $height, textColor: $viewModel.textColor, textFont: $viewModel.font, fontSize: $viewModel.fontSize, range: $viewModel.range, text: $viewModel.docText, keyboardHeight: $constantKeyboardHeight, didEndTyping: { cursor in
                            
                            viewModel.didEndTyping(cursor: cursor)
                        })
                            .introspectTextView(customize: { view in
                                textView = view
                                viewModel.textView = textView
                            })
                        .frame(height: height)
                        .padding()
                        .padding(.bottom, keyboard.currentHeight > 0 ? keyboard.currentHeight : 0)
                        .padding(.bottom, showMenu ?  500 : 0)
                        .edgesIgnoringSafeArea(.all)
//                        .overlay(
//                            collaboratorCursors
//
//                        )
                    }
                    .padding(.top, 40)
                    .onChange(of: keyboard.currentHeight) { height  in
                        if height != 0 {
                            constantKeyboardHeight = height
                        }
                    }
                    
                }

            }
            .introspectScrollView(customize: { view in
                scrollView = view
            })
            .overlay(
                Color.darkBackgroundColor
                    .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top)
                    .edgesIgnoringSafeArea(.top)
                , alignment: .top)
            .overlay(toolBar, alignment: .top)
            
        }
        .overlay(
            menu
                .frame(height: 400)
                .edgesIgnoringSafeArea(.bottom)
            , alignment: .bottom)
        .overlay(
            saveButton
            , alignment: .bottom
        )
        .navigationBarHidden(true)
        .sheet(isPresented: $showColorPicker) {
            VStack {
                
                HStack {
                    Spacer ()
                    
                    Button {
                        showColorPicker.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .imageScale(.large)
                            .padding(.all)
                    }

                }
                
                ColorPickerWellView(selectedColor: viewModel.range.length != 0 ? $viewModel.highlightedColor : $viewModel.textColor) {
                    withAnimation {
                        viewModel.applyAttribute(attributeType: .textColor)
                    }
                }
            }
            
        }
        .sheet(isPresented: $showHighlightColorPicker) {
            VStack {
                
                HStack {
                    Spacer ()
                    
                    Button {
                        showHighlightColorPicker.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .imageScale(.large)
                            .padding(.all)
                    }

                }
                
                ColorPickerWellView(selectedColor: $viewModel.textHighlightColor) {
                    withAnimation {
                        viewModel.applyAttribute(attributeType: .highlightColor)
                    }
                }
            }
            
        }
        .modal(modalConfiguration: ModalConfiguration(isPresenting: $showSettingView, modalTitle: "Settings", backgroundColor: .darkBackgroundColor, exitButtonColor: .white)) {
            settingsView
            
        }
        .modal(modalConfiguration: ModalConfiguration(isPresenting: $showFontPicker, modalTitle: "Fonts", backgroundColor: .darkBackgroundColor, exitButtonColor: .white)) {
            fontPicker
        }
        .modal(modalConfiguration: ModalConfiguration(isPresenting: $showLinkSetter, modalTitle: "Link", backgroundColor: .darkBackgroundColor, exitButtonColor: .white)) {
            addLink
        }
        .onAppear(perform: {
            viewModel.didAppear()
        })
        .onDisappear(perform: {
            viewModel.didDisappear()
        })
        
        

    }
    
    var addLink: some View {
        VStack {
            
            TextfieldWithoutBorder(text: $viewModel.linkURL, placeholder: "URL", textColor: .white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(height: 50)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, 20)
                .onAppear(perform: {
                    viewModel.tempRange = viewModel.range
                })
            
            if viewModel.isHighlightedTextLink {
                Divider()
                    .background(Color.gray)
                    .padding(.horizontal)
                
                Button {
                    viewModel.openLink()
                } label: {
                    HStack {
                        Text("Open link")
                            .foregroundColor(.white)

                            
                    }
                    .padding(.vertical, 10)
                    
                }
                .padding(.horizontal)
                
                
                Divider()
                    .background(Color.gray)
                    .padding(.horizontal)
            }
            
                            
            
            Button {
                
                if viewModel.isHighlightedTextLink {
                    viewModel.removeLink()
                    showLinkSetter = false
                } else {
                    viewModel.applyAttribute(attributeType: .link)
                    showLinkSetter = false
                }

                                    
            } label: {
                Text(viewModel.isHighlightedTextLink ? "Remove": "Add")
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
    
    var collaboratorCursors: some View {
        ZStack {
            ForEach(Array(viewModel.collaboratorsPositions), id: \.0) { user in
                if viewModel.liveMode && viewModel.collaborators[user.key]?.online ?? false && user.key != CurrentUser.shared.currentUser.id {
                    Rectangle()
                        .fill(viewModel.collaboratorsColors[user.key] ?? .clear)
                        .frame(width: user.value.2, height: user.value.3 )
                        .position(x: user.value.0, y: user.value.1 - user.value.3)
//                        .padding(.top, -40 - user.value.3)
                }
            }
        }
    }
    
    var settingsView: some View {
        VStack(alignment: .leading) {
            
            HStack {
                
                
                Spacer()
                
                Toggle(isOn: $viewModel.liveMode, label: {
                    HStack {
                        
                        Text("Live mode")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                })
                
            }
            .padding(.horizontal)
            .padding(.vertical)
            .onChange(of: viewModel.liveMode, perform: { value in
                if !value {
                    viewModel.stopListener()
                } else {
                    viewModel.restartListener()
                }
            })
            
            Text("Collaborators")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.leading)
                .padding(.top)
            
            LazyVStack {
                ForEach(Array(viewModel.collaborators.values), id: \.id) { user in
                    HStack {
                        Text(user.displayName)
                            .foregroundColor(viewModel.collaboratorsColors[user.id])
                            .font(.system(size: 16, weight: .regular, design: .default))
                        
                        Spacer()
                        
                        if viewModel.documentState.currentDocument.createdBy == user.id {
                            Text("Owner")
                                .foregroundColor(.gray)
                                .font(.system(size: 14, weight: .light, design: .default))
                        }
                    }
                    
                    Divider()
                        .background(Color.gray)
                }
                
                
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            Text("Share")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.leading)
                .padding(.top)
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal)
            
            Button {
                viewModel.createSharableCode()
            } label: {
                HStack {
                    Text("Copy link")
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(viewModel.showCopied ? "checkmark" : "clipboard")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(viewModel.showCopied ? .blue : .white)
                        .frame(width: 25, height: 20)
                        .padding(.leading)

                        
                }
                .padding(.vertical, 10)
                
            }
            .padding(.horizontal)
            
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal)
        }
        .padding(.bottom, 40)
        
    }
    
    var fontPicker: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.allFonts, id: \.self) { font in

                Button {
                    
                    if viewModel.range.length != 0 {
                        viewModel.highlightedFont =  UIFont(name: font, size: 16) ?? .systemFont(ofSize: 16)
                    } else {
                        viewModel.font =  UIFont(name: font, size: 16) ?? .systemFont(ofSize: 16)
                    }
                    
                    viewModel.applyAttribute(attributeType: .font)
                    showFontPicker.toggle()

                } label: {
                    VStack {
                        HStack {
                            Text(font)
                                .font(Font(UIFont(name: font, size: 16) ?? .systemFont(ofSize: 16)))
                                .foregroundColor(.white)

                            Spacer()

                            Image("checkmark")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.blue)
                                .frame(width: 20, height: 20)
                                .opacity(viewModel.font.fontName == font ? 1 : 0)



                        }
                        .padding(.horizontal)
                    }
                }

                Divider()
                    .background(Color.gray)
                    .padding(.horizontal, 2)

            }
            .padding(.vertical, 8)
        }
         
    }
    
    var saveButton: some View {
        ZStack {
            if textView.isFirstResponder {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            viewModel.saveText()
                        }, label: {
                            Text("save")
                                .foregroundColor(.white)
                                .bold()
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
        }
        
    }
    
    var toolBar: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    presentation.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                      .foregroundColor(.white)
                      .imageScale(.large)
                })

                .padding(.leading)
                
                if !textView.isFirstResponder && showEdit {
                    Text(viewModel.documentState.currentDocument.title)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                
                
                
                
                
                Spacer()
                
                if textView.isFirstResponder && viewModel.showSaved {
                    Text("saved")
                        .underline()
                        .foregroundColor(.gray)
                        
                }
                
                
                
                if !textView.isFirstResponder && showEdit {
                    Button(action: {
                        textView.becomeFirstResponder()
                        showEdit.toggle()
                    }, label: {
                        Image("edit1")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                    })
                    .padding()
                }
                
                if textView.isFirstResponder {
                    Button(action: {
                        textView.resignFirstResponder()
                        showEdit = false
                        showMenu = true
                        
                        if viewModel.range.length != 0 {
                            viewModel.getHighlightedTextColor()
                            viewModel.getHighlightedTextFont()
                            viewModel.getHighlightedTextFontSize()
                            viewModel.isHighlightedBold()
                            viewModel.isHighlightedItalic()
                            viewModel.isHighlightedUnderlined()
                            viewModel.isHighlightedLink()
                            viewModel.getTextBackgroundColor()
                        }
                        
                    }, label: {
                        Image("mode_edit")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                    })
                    .padding()
                }
                
               
                if textView.isFirstResponder || !showEdit {
                    Button(action: {
                        textView.resignFirstResponder()
                        showEdit = true
                        showMenu = false
                        viewModel.isHighlightedTextBold = false
                        viewModel.isHighlightedTextItalic = false
                        viewModel.isHighlightedTextUnderlined = false
                        viewModel.isHighlightedTextLink = false

                    }, label: {
                        Image("checkmark")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                    })
                    .padding()
                }
                
                if textView.isFirstResponder {
                    Button(action: {
                        showEdit = false
                        textView.resignFirstResponder()
                        showSettingView = true
                        
                        
                        
                    }, label: {
                        Image("menu")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                    })
                    .padding()
                }
            }
            
        }
        .background(Color.darkBackgroundColor)
        .frame(maxWidth: .infinity)
        .overlay(
            VStack {
                Spacer()
                Divider()
                    .shadow(color: Color.gray.opacity(0.3), radius: 3)
            }
        )
        
        
    }
    
    var menu: some View {
        ZStack {
            if showMenu && !textView.isFirstResponder {
                ZStack {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            
                            topEditingTools
                            
                            fontSize
                            
                            lineSpacing
                            
                            midEditingTools
                            

                            
                        }
                        .padding(.vertical, 18)
                        .padding(.horizontal, 30)
                        
                       
                    }
                }
                .transition(.opacity)
                .background(Color.darkModalColor)
                .edgesIgnoringSafeArea(.bottom)
                
            }

        }
    }
    
    var lineSpacing: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Line spacing")
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack {
                    Button {
                        if viewModel.range.length != 0 {
                            viewModel.highlightedlineSpacing += 1
                        } else {
                            viewModel.lineSpacing += 1
                        }
                        
                    } label: {
                        Image("add")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 25, height: 20)
                            .padding(.horizontal)
                    }
                    
                    
                    TextField("", text: $viewModel.lineSpacing.asString)
                        .disabled(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .frame(width: 60, height: 60)
                    
                    Button {
                        if viewModel.range.length != 0 {
                            viewModel.highlightedlineSpacing -= 1
                        } else {
                            viewModel.lineSpacing -= 1
                        }
                        
                    } label: {
                        Image("remove")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 25, height: 20)
                            .padding(.leading)
                    }


                }

                    
            }
            .padding(.vertical, 4)
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal, 2)
        }
    }
    
    var fontSize: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Size")
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack {
                    Button {
                        if viewModel.range.length != 0 {
                            viewModel.highlightedFontSize += 1
                        } else {
                            viewModel.fontSize += 1
                        }
                        
                        viewModel.applyAttribute(attributeType: .fontSize)
                        
                        
                    } label: {
                        Image("add")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 25, height: 20)
                            .padding(.horizontal)
                    }
                    
                        
                    
                    TextField("", text: viewModel.range.length != 0 ? $viewModel.highlightedFontSize.asString : $viewModel.fontSize.asString)
                        .disabled(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .frame(width: 60, height: 60)
                    
                    Button {
                        if viewModel.range.length != 0 {
                            viewModel.highlightedFontSize -= 1
                        } else {
                            viewModel.fontSize -= 1
                        }
                        
                        viewModel.applyAttribute(attributeType: .fontSize)
                        
                    } label: {
                        Image("remove")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 25, height: 20)
                            .padding(.leading)
                    }


                }

                    
            }
            .padding(.vertical, 4)
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal, 2)
        }
    }
    
    var topEditingTools: some View {
        VStack {
            Button {
                showColorPicker.toggle()
            } label: {
                HStack {
                    Text("Text Color")
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Circle()
                        .fill(viewModel.range.length != 0 ? viewModel.highlightedColor : viewModel.textColor)
                        .frame(width: 25, height: 25)

                        
                }
                
            }
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal, 2)
            
            Button {
                showFontPicker.toggle()
            } label: {
                HStack {
                    Text("Font")
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(viewModel.range.length != 0 ? viewModel.highlightedFont.fontName : viewModel.font.fontName)
                        .font(viewModel.range.length != 0 ? Font(viewModel.highlightedFont) : Font(viewModel.font))
                        .foregroundColor(.white)

                        
                }
                
            }
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal, 2)
        }
    }
    
    var midEditingTools: some View {
        VStack(alignment: .leading) {
            HStack {
                
                Button {
                    viewModel.applyAttribute(attributeType: .bold)
                } label: {
                    Image("bold")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .padding(viewModel.isHighlightedTextBold ? 3: 0)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.isHighlightedTextBold ? Color.darkBackgroundColor: Color.clear)
                        )
                        .padding(.horizontal)
                        
                }
                
                
                
                Spacer()
                
                Button {
                    viewModel.applyAttribute(attributeType: .italics)
                } label: {
                    Image("italic")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .padding(viewModel.isHighlightedTextItalic ? 3: 0)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.isHighlightedTextItalic ? Color.darkBackgroundColor: Color.clear)
                        )
                        .padding(.horizontal)
                }
                
                
                
                Spacer()
                
                Button {
                    viewModel.applyAttribute(attributeType: .underline)
                } label: {
                    Image("underlined")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .padding(viewModel.isHighlightedTextUnderlined ? 3 : 0)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.isHighlightedTextUnderlined ? Color.darkBackgroundColor: Color.clear)
                        )
                        .padding(.horizontal)
                }
                
                
                Spacer()
                
                Button {
                    showLinkSetter = true
                } label: {
                    Image("link")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .padding(3)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.isHighlightedTextLink ? Color.darkBackgroundColor: Color.clear)
                        )
                        .padding(.horizontal)
                }
                
                
                Spacer()
                
                Button {
                    viewModel.isHighlightedPainted()
                    if viewModel.isHighlightedTextPainted {
                        viewModel.removeHighlightedTextPaint()
                    } else {
                        showHighlightColorPicker = true
                    }
                    
                } label: {
                    Image("highlight")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(viewModel.range.length != 0 ? viewModel.highlightedTextHighlightColor: .white)
                        .frame(width: 30, height: 30)
                        .padding(.horizontal)
                }

            }
            
            .padding(.vertical, 8)
            
            Divider()
                .background(Color.gray)
                .padding(.horizontal, 2)
        }
    }
    

}



