//
//  StalkNetwork.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/15/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Combine
import Foundation
import WebKit
import SwiftUI

public struct SUIWebView: UIViewRepresentable {
    let webView: WKWebView
    
    public func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}

public class WKWebViewLoadWrapper: NSObject, WKNavigationDelegate {
    private var finishedLoading: PassthroughSubject<WKWebView, Never> = PassthroughSubject()
    public var page: WKWebView
    
    public init(page: WKWebView) {
        self.page = page
        super.init()
        self.page.navigationDelegate = self
    }
    
    func load(request: URLRequest) -> AnyPublisher<WKWebView, Never> {
        self.page.load(request)
        return self.finishedLoading.eraseToAnyPublisher()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.finishedLoading.send(webView)
    }
}

public struct StalkNetwork: StalkMarketWizardNetworkInterface {
    var marketURL: URL = URL(string: "https://kurtboyer.com/stalkmarket/")!
    
    var web: WKWebView
    var loader: WKWebViewLoadWrapper
    var stalkPage: StalkMarketPage
    var recommendationPage: StalkMarketRecommendationPage
    
    init() {
        web = WKWebView()
        loader = WKWebViewLoadWrapper(page: web)
        stalkPage = StalkMarketPage(webView: web)
        recommendationPage = StalkMarketRecommendationPage(webView: web)
    }
    
//    func reset() -> AnyPublisher<WKNavigation, Never> {
//        return loader.load(request: URLRequest(url: marketURL))
//    }
    
    public func prediction(from week: WeekModel?) -> AnyPublisher<String, Never> {
//        self.web.load(URLRequest(url: marketURL))
        return self.loader.load(request: URLRequest(url: marketURL))
            .flatMap { _ in self.stalkPage.fill(form: week) >> self.stalkPage.trigger() }
            .flatMap { _ in self.recommendationPage.recommendation() }
            .eraseToAnyPublisher()
    }
    
    func tryPage() -> AnyPublisher<StalkMarketRecommendationPage, Never> {
        let page = StalkMarketPage(webView: self.web)
        return page
        .fill(form: WeekModel(monday: DayModel(day: Date(), morning: 2, afternoon: 3), tuesday: DayModel(day: Date(), morning: 100, afternoon: nil), wednesday: nil, thursday: nil, friday: nil, saturday: nil, sunday: nil))
        .flatMap() { _ in
            return page.trigger().replaceError(with: StalkMarketRecommendationPage(webView: self.web))
        }
        .eraseToAnyPublisher()
        
    }
}

func const<A, T>(_ v: T) -> (A) -> T {
    return { _ in v }
}

infix operator >>: AdditionPrecedence
public func >><P1: Publisher, P2: Publisher, E>(lhs: P1, rhs: P2) -> Publishers.FlatMap<P2, P1> where P1.Failure == E {
    return lhs.flatMap(const(rhs))
}

extension Int {
    var stringValue: String { "\(self)" }
}

public class JavascriptQuery<T>: Publisher {
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
                self.drop.send(completion: .finished)
            }
        }
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.drop.receive(subscriber: subscriber)
    }
}

struct StalkMarketPage {
    var webView: WKWebView
    
    func fill(form: WeekModel?) -> AnyPublisher<Any?, Never> {
        let path = set(field: "monam", to: form?.monday?.morning)
                >> set(field: "monpm", to: form?.monday?.afternoon)
                >> set(field: "tueam", to: form?.tuesday?.morning)
                >> set(field: "tuepm", to: form?.tuesday?.afternoon)
                >> set(field: "wedam", to: form?.wednesday?.morning)
                >> set(field: "wedpm", to: form?.wednesday?.afternoon)
                >> set(field: "thuam", to: form?.thursday?.morning)
                >> set(field: "thupm", to: form?.thursday?.afternoon)
                >> set(field: "friam", to: form?.friday?.morning)
                >> set(field: "fripm", to: form?.friday?.afternoon)
                >> set(field: "satam", to: form?.saturday?.morning)
                >> set(field: "satpm", to: form?.saturday?.afternoon)
        
        return path.replaceError(with: nil).eraseToAnyPublisher()
    }
    
    func trigger() -> AnyPublisher<StalkMarketRecommendationPage, Never> {
        return Future { promise in
            self.webView.evaluateJavaScript("document.querySelectorAll('form[action=\"wizard.php\"]')[0].submit()") { _, err in
                promise(.success(StalkMarketRecommendationPage(webView: self.webView)))
            }
        }.flatMap { _ in
            return self.webView.publisher(for: \.isLoading).filter { $0 }.prefix(1).map { _ in StalkMarketRecommendationPage(webView: self.webView) }
        }
        .eraseToAnyPublisher()
    }
    
    func set(field: String, to: Int?) -> Future<Any?, Error> {
        return set(field: field, to: (to ?? 0).stringValue)
    }
    
    func set(field: String, to: String) -> Future<Any?, Error> {
        return Future { promise in
            let setString = "document.getElementsByName('\(field)')[0].value = '\(to)';"
            self.webView.evaluateJavaScript(setString, completionHandler: { value, error in
                if let err = error {
                    promise(.failure(err))
                } else {
                    promise(.success(value))
                }
            })
        }
    }
}

extension WKWebView {
    func evaluate<T>(javascript: String) -> JavascriptQuery<T> {
        return JavascriptQuery(webView: self, query: javascript)
    }
}

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
    
    func recommendation() -> AnyPublisher<String, Never> {
        return self.validContent().eraseToAnyPublisher()
    }
    
    func validContent() -> AnyPublisher<String, Never> {
        let evaluation: JavascriptQuery<String> = self.webView.evaluate(javascript: "document.documentElement.outerHTML.toString()")
        return evaluation
            .replaceError(with: "")
            .flatMap() { (content: String) -> AnyPublisher<String, Never> in
                guard let answer = self.parse(recommendation: content) else {
                    return self.retryLater()
                }
                return Future<String, Never> { $0(.success(answer)) }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func retryLater() -> AnyPublisher<String, Never> {
        return Future { $0(.success("")) }.receive(on: DispatchQueue.global())
            .map(self.sleepThenReturn(for: 1))
            .receive(on: RunLoop.main)
            .flatMap { _ in self.validContent() }
            .eraseToAnyPublisher()
    }
    
    func sleepThenReturn<T>(for time: UInt32) -> (T) -> T {
        return { value in
            sleep(time)
            return value
        }
    }
    
    func parse(recommendation content: String) -> String? {
        guard let upperBound = content.range(of: self.recommendationPhrase)?.upperBound else {
             return nil
        }
        let laterSlice = content[upperBound...]
        guard let lastIndex = laterSlice.firstIndex(of: "<") else {
            return nil
        }
        return String(laterSlice[..<lastIndex])
    }
}
