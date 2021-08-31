//
//  TextView.swift
//  LiveDocs
//
//  Created by Samuel Tsokwa on 2021-08-31.
//

import Foundation
import UIKit
import SwiftUI

struct TextView: UIViewRepresentable {
 
    @Binding var height: CGFloat
    @Binding var textColor: Color
    @Binding var textFont: UIFont
    @Binding var fontSize: CGFloat
    @Binding var range: NSRange
    @Binding var text: NSMutableAttributedString
    @Binding var keyboardHeight: CGFloat
//    @Binding var
    var didEndTyping: ((CGRect) -> ())?
 
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isSelectable = true
        textView.delegate = context.coordinator
        textView.showsVerticalScrollIndicator = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = true
        return textView
    }
 
    func updateUIView(_ uiView: UITextView, context: Context) {
        let currentRange = uiView.selectedRange
        uiView.attributedText = text
        uiView.selectedRange = currentRange
        
        
        DispatchQueue.main.async {
            height = uiView.contentSize.height
        }

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($text, height: $height, keyboardHeight: $keyboardHeight, textColor: $textColor, textFont: $textFont, fontSize: $fontSize, range: $range, didEndTyping: didEndTyping)
    }
     
    class Coordinator: NSObject, UITextViewDelegate {
        var didEndTyping: ((CGRect) -> ())?
        private var cursorScrollPositionAnimator: UIViewPropertyAnimator?
        var timer: Timer? = nil
        private var parentScrollView: UIScrollView?
        private var cursor: UIView?
        var text: Binding<NSMutableAttributedString>
        var height: Binding<CGFloat>
        var fontSize: Binding<CGFloat>
        var keyboardHeight: Binding<CGFloat>
        var textColor: Binding<Color>
        var textFont: Binding<UIFont>
        var range: Binding<NSRange>
     
        init(_ text: Binding<NSMutableAttributedString>, height: Binding<CGFloat>, keyboardHeight: Binding<CGFloat>, textColor: Binding<Color>, textFont: Binding<UIFont>, fontSize: Binding<CGFloat>, range: Binding<NSRange>, didEndTyping: ((CGRect) -> ())?) {
            self.text = text
            self.fontSize = fontSize
            self.textColor = textColor
            self.didEndTyping = didEndTyping
            self.textFont = textFont
            self.keyboardHeight = keyboardHeight
            self.height = height
            self.range = range
        }
     
        func textViewDidChange(_ textView: UITextView) {
           
            self.text.wrappedValue =  NSMutableAttributedString(attributedString: textView.attributedText)
            
            
            if textView.textColor != UIColor(textColor.wrappedValue) {
                textView.textColor = UIColor(textColor.wrappedValue)
            }
            
            if textView.font != textFont.wrappedValue {
                textView.font = textFont.wrappedValue
            }
                        
            if textView.font?.pointSize != fontSize.wrappedValue {
                guard let newFont = UIFont(name: textFont.wrappedValue.fontName, size: fontSize.wrappedValue) else { return }
                textView.font = newFont
            }
            
            
            DispatchQueue.main.async {
                self.height.wrappedValue = textView.contentSize.height
            }
            
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            
            self.text.wrappedValue =  NSMutableAttributedString(attributedString: textView.attributedText)
            

            if let range = textView.selectedRange {
                self.range.wrappedValue = range
                if self.range.wrappedValue.length == 0 {
//                    ensureCursorVisible(textView: textView)
                }
            }
            
            if parentScrollView == nil {
                parentScrollView = findParentScrollView(of: textView)
            }
            

        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            timer?.invalidate()
            timer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(textViewDidStopTyping),
                userInfo: ["textField": textView],
                repeats: false)
                return true
        }
        
        @objc func textViewDidStopTyping(timer: Timer) {
           
            guard let userInfo = timer.userInfo as? [String: UITextView] else { return  }
            guard let textView = userInfo["textField"] else { return  }
            guard let range = textView.selectedTextRange else { return  }

            let cursorRect = textView.caretRect(for: range.start)
//            var rectToMakeVisible = textView.convert(cursorRect, to: parentScrollView)
//            rectToMakeVisible.origin.y -= cursorRect.height
            
//            cursor = UIView(frame: rectToMakeVisible)
//            cursor?.backgroundColor = .red
//            let t = UIView(frame: cursorRect)
//
//            if let cursor = cursor {
//                parentScrollView?.addSubview(cursor)
//                parentScrollView?.addSubview(t)
//            }

            if let completion = didEndTyping {
                completion(cursorRect)
            }
        }
        
        private func findParentScrollView(of view: UIView) -> UIScrollView? {
            var current = view
            while let superview = current.superview {
                if let scrollView = superview as? UIScrollView {
                    return scrollView
                } else {
                    current = superview
                }
            }
            return nil
        }

        private func ensureCursorVisible(textView: UITextView) {
            guard let scrollView = findParentScrollView(of: textView), let range = textView.selectedTextRange else {
                return
            }
            
            let cursorRect = textView.caretRect(for: range.start)
            var rectToMakeVisible = textView.convert(cursorRect, to: scrollView)
            rectToMakeVisible.origin.y -= cursorRect.height
            rectToMakeVisible.size.height *= 3
            
            let animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
                scrollView.scrollRectToVisible(rectToMakeVisible, animated: false)
            }
            
            animator.startAnimation()
            self.cursorScrollPositionAnimator = animator
            
        }
    }
}

final class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published private(set) var currentHeight: CGFloat = 0
    

    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}


extension UITextInput {
    var selectedRange: NSRange? {
        guard let range = selectedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
}


extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

extension Binding where Value == CGFloat {
    var asString: Binding<String> {
        let new = Binding<String>(
            get: {self.wrappedValue.description},
            set: { _ in}
        )
        
        return new
    }
}




struct ColorPickerWellView: UIViewControllerRepresentable {
    
    @Binding var selectedColor: Color
    let onColorPicked: () -> Void
    
    init(selectedColor: Binding<Color>, onColorPicked: @escaping () -> Void) {
        self._selectedColor = selectedColor
        self.onColorPicked = onColorPicked
    }
    
    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let controller = UIColorPickerViewController()
        controller.selectedColor = UIColor(selectedColor)
        controller.delegate = context.coordinator

        return controller
    }

    func updateUIViewController(_ colorPickerViewController: UIColorPickerViewController, context: Context) {
        
    }

    
    func updateUIView(_: UIView, context _: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            color: $selectedColor, onColorPicked: self.onColorPicked
        )
    }
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        private let onColorPicked: () -> Void
        var color: Binding<Color>
        
        init(color: Binding<Color>, onColorPicked: @escaping () -> Void) {
            self.onColorPicked = onColorPicked
            self.color = color
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            color.wrappedValue = viewController.selectedColor.color
            onColorPicked()
        }
        
        
    }
}

struct HighlightTextView: UIViewRepresentable {

    let text: NSMutableAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isSelectable = true
        textView.showsVerticalScrollIndicator = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        
        let range: NSRange = NSRange(location: 0, length: text.length)
        text.enumerateAttribute(.font , in: range, options: [.longestEffectiveRangeNotRequired]) { value, range, isStop in
            if let value = value {
                guard let font = (value as? UIFont) else { return }
                textView.font = UIFont(name: font.fontName, size: 5)
                
            }
        }
        return textView
    }
 
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = text
    }
}
