//
//  DateExtension.swift
//  Entry
//
//  Created by 松岡 利人 on 2019/08/26.
//

import Foundation

extension Date {

    /// 時分秒が00:00:00のDateを生成し返す。
    ///
    /// - Returns:
    ///   - 時分秒が00:00:00のDateのインスタンス
    var startOfDay: Date {
        return Calendar(identifier: .gregorian).startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        let calender = Calendar(identifier: .gregorian)
        return calender.date(from: calender.dateComponents([.year, .month], from: self))!
    }

    /// 指定したフォーマットの日付けの文字列からDateを生成し返す。
    /// formatを指定しない場合デフォルトのformatが適用される
    ///
    /// - Parameters:
    ///   - format: フォーマット
    ///   - date: 日付けの文字列
    /// - Returns:
    ///   - Dateのインスタンス
    init?(format: String, date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = dateFormatter.date(from: date) else {
            return nil
        }
        self = date
    }

    /// 指定したフォーマットの文字列を生成し返す。
    /// formatを指定しない場合デフォルトのformatが適用される
    ///
    /// - Parameters:
    ///   - format: フォーマット
    /// - Returns:
    ///   - 生成された文字列
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }
}
