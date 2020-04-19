//
//  ACSWebMessenger.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import Combine
import WebKit

public struct ACSWebViewMessage: Decodable {
    public let value: String
    public let identifier: String
    
    static let decoder: JSONDecoder = JSONDecoder()
    
    func getValue<T: Decodable>() throws -> T {
        return try ACSWebViewMessage.decoder.decode(T.self, from: value.data(using: .utf8)!)
    }
}

class ACSWebViewMessenger: NSObject, WKScriptMessageHandler, Publisher {
    typealias Output = ACSWebViewMessage
    typealias Failure = Never
    
    let messageChannel = "acsWebMessage"
    var webView: WKWebView
    private let drop: PassthroughSubject<ACSWebViewMessage, Never>
    private let decoder = JSONDecoder()
    
    override init() {
        self.drop = PassthroughSubject()
        self.webView = WKWebView()
        super.init()
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: messageChannel)
        let callback = """
        function completeFormSubmission(identifier) {
            var object = { 'object': { 'value': 'Complete', 'identifier': identifier } }
            webkit.messageHandlers.\(self.messageChannel).postMessage(object);
        };
        """
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
        
        let callbackScript = WKUserScript(source: callback, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        self.webView.configuration.userContentController.addUserScript(callbackScript)
        
        self.webView = WKWebView(frame: CGRect(x: 1, y: 1, width: 1, height: 1), configuration: configuration)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == messageChannel {
            guard let messageContent = message.body as? String else {
                return
            }
            guard let data = messageContent.data(using: .utf8) else {
                return
            }
            if let acsMessage = try? decoder.decode(ACSWebViewMessage.self, from: data) {
                self.drop.send(acsMessage)
            }
        }
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, ACSWebViewMessage == S.Input {
        self.drop.receive(subscriber: subscriber)
    }
}

extension ACSWebViewMessenger {
    func submit(element: String) -> AnyPublisher<WKWebView, Error> {
        let objQuery = "document.querySelectorAll('\(element)')[0]"
        let formSubmission = "\(objQuery).submit();"
        return JavascriptExpression(webView: self.webView, query: formSubmission)
            .map { (_: Any?) -> WKWebView in
                self.webView
            }
            .eraseToAnyPublisher()
    }
}
