//
//  TodoWidgetBundle.swift
//  TodoWidget
//
//  Created by ckr on 2/25/26.
//

import WidgetKit
import SwiftUI

@main
struct TodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodoWidget()
        TodoWidgetControl()
    }
}
