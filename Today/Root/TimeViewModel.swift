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
    
    var currentDate: Observable<Date> { get }
}

class TimeViewModel: RootViewModel {
    
    fileprivate let lastDate = Variable(Date())
    
    override init() {
        super.init()
        
        Observable<Int>
            .interval(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
            self?.lastDate.value = Date()
        }).disposed(by: disposeBag)
    }
}

extension TimeViewModel: TimeViewModelType {
    
    var currentDate: Observable<Date> {
        return lastDate.asObservable()
    }
}
