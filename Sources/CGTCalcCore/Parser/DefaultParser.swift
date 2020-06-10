//
//  DefaultParser.swift
//  CGTCalcCore
//
//  Created by Matt Galloway on 09/06/2020.
//

import Foundation

enum ParserError: Error {
  case IncorrectNumberOfFields(String)
  case InvalidKind(String)
  case InvalidDate(String)
  case InvalidAmount(String)
  case InvalidPrice(String)
  case InvalidExpenses(String)
}

public class DefaultParser {
  private let dateFormatter: DateFormatter
  private var nextId: Int = 0

  public init() {
    self.dateFormatter = DateFormatter()
    self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    self.dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    self.dateFormatter.dateFormat = "dd/MM/yyyy"
  }

  public func transactions(fromData data: String) throws -> [Transaction] {
    return try data
      .split { $0.isNewline }
      .compactMap { try self.transaction(fromData: String($0)) }
  }

  public func transaction(fromData data: String) throws -> Transaction? {
    guard data.count > 0 && data[data.startIndex] != "#" else {
      return nil
    }

    let splitData = data.components(separatedBy: .whitespaces)
    guard splitData.count == 6 else {
      throw ParserError.IncorrectNumberOfFields(data)
    }

    let kind: Transaction.Kind
    switch splitData[0] {
    case "BUY":
      kind = .Buy
    case "SELL":
      kind = .Sell
    case "ADJ":
      kind = .Section104Adjust
    default:
      throw ParserError.InvalidKind(data)
    }

    guard let date = dateFormatter.date(from: splitData[1]) else {
      throw ParserError.InvalidDate(data)
    }

    let asset = splitData[2]

    guard let amount = Decimal(string: splitData[3]) else {
      throw ParserError.InvalidAmount(data)
    }

    guard let price = Decimal(string: splitData[4]) else {
      throw ParserError.InvalidPrice(data)
    }

    guard let expenses = Decimal(string: splitData[5]) else {
      throw ParserError.InvalidExpenses(data)
    }

    let id = self.nextId
    self.nextId += 1

    return Transaction(id: id, kind: kind, date: date, asset: asset, amount: amount, price: price, expenses: expenses)
  }
}
