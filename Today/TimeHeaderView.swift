//
//  TimeHeaderView.swift
//  Today
//
//  Created by James Harquail on 2017-11-22.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TimeHeaderView: UITableViewHeaderFooterView {
    
    static var reuseIdentifier: String {
        return "\(self)"
    }
    
    private var viewModel: TimeViewModelType?
    fileprivate lazy var disposeBag = DisposeBag()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.frame = contentView.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-UltraLight", size: 80)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(timeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.text = nil
        disposeBag = DisposeBag()
    }
    
    public func inject(model viewModel: TimeViewModelType) {
        viewModel
            .timeString
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
