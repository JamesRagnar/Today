//
//  EventTableViewCell.swift
//  Today
//
//  Created by James Harquail on 2017-11-22.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class EventTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String {
        return "\(self)"
    }
    
    static func desiredHeight() -> CGFloat {
        return 40
    }
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-UltraLight", size: 25)
        label.backgroundColor = UIColor(white: 1, alpha: 0.8)
        label.frame = CGRect(x: 0, y: 0, width: 40, height: self.contentView.bounds.height)
        label.autoresizingMask = [.flexibleHeight]
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-UltraLight", size: 25)
        label.backgroundColor = UIColor(white: 1, alpha: 0.8)
        label.frame = CGRect(x: 40, y: 0, width: self.contentView.bounds.width - 40, height: self.contentView.bounds.height)
        label.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.backgroundColor = .white
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func loadData(from event: Event) {
        timeLabel.text = ""
        titleLabel.text = event.title
    }
}
