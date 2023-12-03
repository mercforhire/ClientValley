//
//  RequiredField.swift
//  crm-finixlab
//
//  Created by Leon Chen on 2021-07-16.
//

import Foundation
import UIKit

class RequiredField {
    weak var fieldLabel: UILabel!
    weak var field: UITextField!
    
    init(fieldLabel: UILabel, field: UITextField) {
        self.fieldLabel = fieldLabel
        self.field = field
    }
}

class RequiredOneField {
    weak var fieldLabel: UILabel!
    weak var field: UITextField!
    
    weak var fieldLabel2: UILabel!
    weak var field2: UITextField!
    
    init(fieldLabel: UILabel, field: UITextField, fieldLabel2: UILabel, field2: UITextField) {
        self.fieldLabel = fieldLabel
        self.field = field
        self.fieldLabel2 = fieldLabel2
        self.field2 = field2
    }
}
