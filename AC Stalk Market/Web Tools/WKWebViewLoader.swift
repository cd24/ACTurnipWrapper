//
//  WKWebViewLoader.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import Combine
import WebKit

public class WKWebViewLoadWrapper: NSObject, WKNavigationDelegate {
    public enum State: Equatable {
        case loading
        case finished
    }
    private var finishedLoading: CurrentValueSubject<State, Never> = CurrentValueSubject(.loading)
    public var page: WKWebView
    
    public init(page: WKWebView) {
        self.page = page
        super.init()
        self.page.navigationDelegate = self
    }
    
    public lazy var latest: CurrentValueSubject<State, Never> = {
        self.finishedLoading
    }()
    
    func load(request: URLRequest) -> AnyPublisher<State, Never> {
        self.page.load(request)
        return self.finishedLoading.eraseToAnyPublisher()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.finishedLoading.value = .finished
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.finishedLoading.value = .loading
    }
}
