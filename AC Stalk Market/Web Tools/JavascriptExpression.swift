//
//  JavascriptExpression.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import WebKit
import Combine

public class JavascriptExpression<T: Unit>: Publisher {
    public typealias Output = T
    public typealias Failure = Error
    
    private let drop = PassthroughSubject<T, Error>()
    
    let webView: WKWebView
    let query: String
    
    public init(webView: WKWebView, query: String) {
        self.webView = webView
        self.query = query
        
        self.webView.evaluateJavaScript(query) { value, error in
            if let expected = value as? T {
                self.drop.send(expected)
                self.drop.send(completion: .finished)
            } else if let errorValue = error {
                self.drop.send(completion: .failure(errorValue))
            } else {
                self.drop.send(T.empty)
                self.drop.send(completion: .finished)
            }
        }
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.drop.receive(subscriber: subscriber)
    }
}
