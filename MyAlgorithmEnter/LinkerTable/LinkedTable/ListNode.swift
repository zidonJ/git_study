//
//  ListNode.swift
//  LinkedTable
//
//  Created by 姜泽东 on 2017/12/26.
//  Copyright © 2017年 MaiTian. All rights reserved.
//  创建链表先创建节点

import UIKit

class ListNode {

    fileprivate var head: ListNode?
    private var tail: ListNode?
    
    var value: Int
    var next: ListNode?
    weak var previous: ListNode?
    
    init(_ value: Int) {
        self.value = value
        self.next = nil
    }
}


