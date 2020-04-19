//
//  StalkMarketPage.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import WebKit
import Combine

struct StalkMarketPage {
    var webView: ACSWebViewMessenger
    
    func fill(form: WeekModel?) -> AnyPublisher<Any?, Error> {
        let path = set(field: "monam", to: form?.monday?.morning)
                >>> set(field: "monpm", to: form?.monday?.afternoon)
                >>> set(field: "tueam", to: form?.tuesday?.morning)
                >>> set(field: "tuepm", to: form?.tuesday?.afternoon)
                >>> set(field: "wedam", to: form?.wednesday?.morning)
                >>> set(field: "wedpm", to: form?.wednesday?.afternoon)
                >>> set(field: "thuam", to: form?.thursday?.morning)
                >>> set(field: "thupm", to: form?.thursday?.afternoon)
                >>> set(field: "friam", to: form?.friday?.morning)
                >>> set(field: "fripm", to: form?.friday?.afternoon)
                >>> set(field: "satam", to: form?.saturday?.morning)
                >>> set(field: "satpm", to: form?.saturday?.afternoon)
        
        return path.eraseToAnyPublisher()
    }
    
    func submit() -> AnyPublisher<StalkMarketRecommendationPage, Error> {
        return self.webView.submit(element: "form[action=\"wizard.php\"]")
            .map(StalkMarketRecommendationPage.init)
            .eraseToAnyPublisher()
    }
    
    func set(field: String, to: Int?) -> AnyPublisher<Any?, Error> {
        return set(field: field, to: (to ?? 0).stringValue)
    }
    
    func set(field: String, to: String) -> AnyPublisher<Any?, Error> {
        return JavascriptExpression(webView: self.webView.webView, query: "document.getElementsByName('\(field)')[0].value = '\(to)';")
            .eraseToAnyPublisher()
    }
}
