//
//  Currency.swift
//  CurrencyConverter
//
//  Created by BJIT on 19/1/24.
//

import Foundation

struct Currency : Hashable{
    let code : String
    let symbol: String
}


class CurrencyState{
    static let currencies: [Currency] = [
    Currency(code: "USD", symbol: "$"),
    Currency(code: "EUR", symbol: "€"),
    Currency(code: "GBP", symbol: "£"),
    Currency(code: "CAD", symbol: "C$")
    ]
}
