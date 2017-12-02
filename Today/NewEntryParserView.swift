//
//  NewEntryParserView.swift
//  Today
//
//  Created by James Harquail on 2017-11-30.
//  Copyright © 2017 Ragnar Development. All rights reserved.
//

import Foundation
import UIKit

class NewEntryParserView: UIView {
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        return textField
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textField.frame = bounds
    }
}
