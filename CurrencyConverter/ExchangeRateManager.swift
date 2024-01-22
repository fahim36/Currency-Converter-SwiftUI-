//
//  ExchangeRateManager.swift
//  CurrencyConverter
//
//  Created by BJIT on 19/1/24.
//

import Foundation


class ExchangeRateManager{
    
    public var delegate : ExchangeRateResponseDelegate? = nil
    static let apiKey = "fca_live_1jBwQftXYrjEH7ks6svcSKzVWhBNwsb8MwbQ6sgG"
    
    let url = "https://api.freecurrencyapi.com/v1/latest?apikey=\(apiKey)"
    
    func fetchRates(for currency: String, toCurrency : String , completion : @escaping(_ exchangeRate: ExchangeRate?) -> Void ){
        self.delegate?.reset()
        
        let url = URL(string: "\(self.url)&base_currency=\(currency)&currencies=\(toCurrency)")!
        
        let task = URLSession.shared.dataTask(with: url){
            data , response , error in
            
            if let err = error {
                self.handleClientError(_error: err)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            guard let httpRespnse = response as? HTTPURLResponse, httpRespnse.statusCode == 200 else {
                self.handleServerError(_error: response)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            if let mimeType = response?.mimeType, mimeType == "application/json",
               let data = data {
                let rate = self.decodeResponse(json: data, for: currency, to: toCurrency)
                DispatchQueue.main.async {
                    completion(rate)
                }
            }else{
                self.handleDecodeError()
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
        }
        task.resume()
    }
    
    func decodeResponse(json: Data, for currency: String , to toCurrency : String ) ->ExchangeRate? {
        do{
            let decoder = JSONDecoder()
            let exchangeRateResponse = try decoder.decode( ExchangeRateResponse.self, from: json)
            
            return exchangeRateResponse.toExchangeRate(from: currency, to: toCurrency)
        } catch {
            return nil
        }
    }
    
    private func handleClientError(_error : Error) {
        delegate?.requestFailedWith(error: _error , type: .client)
    }
    private func handleServerError(_error : URLResponse?) {
        let error = NSError(domain: "API Error", code: 400)
        delegate?.requestFailedWith(error: error , type: .server)
    }
    private func handleDecodeError() {
        let error = NSError(domain: "Decode Error", code: 500)
        delegate?.requestFailedWith(error: error , type: .decode)
    }
}
