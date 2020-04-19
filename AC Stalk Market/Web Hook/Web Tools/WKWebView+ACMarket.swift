//
//  WKWebView+ACMarket.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    func evaluate<T>(javascript: String) -> JavascriptExpression<T> {
        return JavascriptExpression(webView: self, query: javascript)
    }
}
