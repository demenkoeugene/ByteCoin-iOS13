//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation


protocol CoinManagerDelegate {
    func didUpdateCoin(_ currencyExchangeModel: CoinManager, coin: CurrencyExchangeModel)
    func didFailWithError(error: Error)
}

struct CoinManager {

    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    let apiKey = "CEB92E2B-6D85-4472-8880-BB8102660CC8"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","UAH","SEK","SGD","USD","ZAR"]

    func getCoinPrice (for currency: String) {
        let fullURL = baseURL+currency+"?apikey="+apiKey
        performRequest(with: fullURL)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    return
                }
                if let safeData = data {
                    if let currency = self.parseJSON(safeData){
                        self.delegate?.didUpdateCoin(self, coin: currency)
                        print(currency.rate)
                    }
                }
            }
            task.resume()
        }
    }

    
    func parseJSON(_ currencyModel: Data) -> CurrencyExchangeModel? {
           let decoder = JSONDecoder()
           do {
               let decodedData = try decoder.decode(CurrencyExchangeModel.self, from: currencyModel)
               let time = decodedData.time
               let asset_id_base = decodedData.asset_id_base
               let asset_id_quote = decodedData.asset_id_quote
               let rate = decodedData.rate
              
               let currency = CurrencyExchangeModel(time: time,
                                                    asset_id_base: asset_id_base,
                                                    asset_id_quote: asset_id_quote,
                                                    rate: rate)
               return currency
               
           } catch {
               return nil
           }
       }
    
}


struct CurrencyExchangeModel: Decodable{
    let time: String
    let asset_id_base: String
    let asset_id_quote: String
    let rate: Double
}
