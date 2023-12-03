//
//  DelayedSearchTimer.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-17.
//

import Foundation

protocol DelayedSearchTimerDelegate : class {
    func shouldSearch(text: String)
}

class DelayedSearchTimer {
    static let searchDelay: TimeInterval = 0.3
    var timer: Timer?
    
    weak var delegate: DelayedSearchTimerDelegate?
    private var searchedText: String = ""
    
    func textDidGetEntered(text: String) {
        if let timer = timer {
            timer.invalidate()
        }
        searchedText = text
        timer = Timer.scheduledTimer(timeInterval: DelayedSearchTimer.searchDelay,
                                     target: self,
                                     selector: #selector(timerFired),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    @objc func timerFired() {
        timer = nil
        delegate?.shouldSearch(text: searchedText)
    }
}
