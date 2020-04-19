//
//  StalkMarketRecommendationPage.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import Combine
import WebKit

class StalkMarketRecommendationPage: NSObject, WKNavigationDelegate {
    var webView: WKWebView
    let recommendationPhrase = "name=\"recommendation\">"
    private var loadingDrop: PassthroughSubject<WKWebView, Never> = PassthroughSubject()
    
    init(webView: WKWebView) {
        self.webView = webView
        super.init()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadingDrop.send(webView)
    }
    
    func recommendation() -> AnyPublisher<String, Error> {
        let evaluation: JavascriptExpression<String> = self.webView.evaluate(javascript: "document.documentElement.outerHTML.toString()")
        return evaluation
            .tryMap(self.parse)
            .eraseToAnyPublisher()
    }
    
    public enum ParseError: Error {
        case phraseNotFound
        case phraseIsUnbounded
    }
    
    func parse(recommendation content: String) throws -> String {
        guard let upperBound = content.range(of: self.recommendationPhrase)?.upperBound else {
            throw ParseError.phraseNotFound
        }
        let laterSlice = content[upperBound...]
        guard let lastIndex = laterSlice.firstIndex(of: "<") else {
            throw ParseError.phraseIsUnbounded
        }
        return String(laterSlice[..<lastIndex])
    }
}
