//
//  TimeViewModel.swift
//  Today
//
//  Created by James Harquail on 2017-11-22.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import RxSwift

protocol TimeViewModelType {
    
    var timeString: Observable<String?> { get }
}

class TimeViewModel: RootViewModel {
    
    fileprivate let lastDate = Variable(Date())
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    override init() {
        super.init()
        
        Observable<Int>
            .interval(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
            self?.lastDate.value = Date()
        }).disposed(by: disposeBag)
    }
}

extension TimeViewModel: TimeViewModelType {
    
    var timeString: Observable<String?> {
        return lastDate.asObservable().map({ [weak self] (date) -> String? in
            return self?.dateFormatter.string(from: Date())
        })
    }
}
