//
//  ErrorTableViewCell.swift
//  Today
//
//  Created by James Harquail on 2017-12-03.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import UIKit

class ErrorTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String {
        return "\(self)"
    }
    
    static func desiredHeight(for event: Event) -> CGFloat {
        return event.address == nil ? 40 : 200
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.backgroundColor = .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
