//
//  KBStalkNetwork.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/15/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Combine
import Foundation
import WebKit
import SwiftUI

public struct KBStalkNetwork: StalkMarketWizardNetworkInterface {
    var marketURL: URL = URL(string: "https://kurtboyer.com/stalkmarket/")!
    
    public func prediction(from week: WeekModel?) -> AnyPublisher<String, Error> {
        let web: ACSWebViewMessenger = ACSWebViewMessenger()
        let loader: WKWebViewLoadWrapper = WKWebViewLoadWrapper(page: web.webView)
        
        return loader.load(request: URLRequest(url: marketURL))
            .filter { $0 == .finished }
            .prefix(1)
            .map { _ in StalkMarketPage(webView: web) }
            .normalizeError()
            .flatMap { stalkPage in stalkPage.fill(form: week) >>> stalkPage.submit() }
            .flatMap { recommendation in loader.latest.filter { $0 == .loading }.map { _ in recommendation }.normalizeError() }
            .flatMap { recommendation in loader.latest.filter { $0 == .finished }.map { _ in recommendation }.normalizeError() }
            .flatMap { recommendationPage in recommendationPage.recommendation() }
            .eraseToAnyPublisher()
    }
}

public struct KBNetworkParser: StalkMarketWizardParser {
    public func parse(from content: String) -> TurnipPrediction<Error> {
        if content.lowercased().contains("sell") {
            return .sell
        } else {
            return .hold
        }
    }
}


