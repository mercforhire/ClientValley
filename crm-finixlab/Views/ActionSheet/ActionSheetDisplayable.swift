//
//  ActionSheetDisplayable.swift
//  Phoenix
//
//  Created by Leon Chen on 2018-11-20.
//  Copyright © 2018 Symbility Intersect. All rights reserved.
//

import UIKit

protocol ActionSheetDisplayable: class {
    var actionSheet: ActionSheet? { get set }
    func calculateHeight() -> CGFloat
}
