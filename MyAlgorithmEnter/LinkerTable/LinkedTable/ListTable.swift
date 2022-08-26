//
//  ListTable.swift
//  LinkedTable
//
//  Created by 姜泽东 on 2017/12/26.
//  Copyright © 2017年 MaiTian. All rights reserved.
//

import UIKit

class ListTable: NSObject {

    var head: ListNode?
    var tail: ListNode?
    
    // 尾插法
    func appendToTail(_ value: Int) {
        if tail == nil {
            tail = ListNode(value)
            head = tail
        } else {
            tail!.next = ListNode(value)
            tail = tail!.next
        }
    }
    
    // 头插法
    func appendToHead(_ value: Int) {
        if head == nil {
            head = ListNode(value)
            tail = head
        } else {
            let temp = ListNode(value)
            temp.next = head
            head = temp
        }
    }
    
    //链表中是否有环
    /*
     笔者理解快行指针,就是两个指针访问链表,一个在前一个在后,或者一个移动快另一个移动慢,这就是快行指针。
     所以如何检测一个链表中是否有环?->用两个指针同时访问链表,其中一个的速度是另一个的2倍,如果他们相等了,那么这个链表就有环了。
     */
    func hasCycle(_ head: ListNode?) -> Bool {
        var slow = head
        var fast = head
        
        while fast != nil && fast!.next != nil {
            slow = slow!.next
            fast = fast!.next!.next
            
            if slow === fast {
                return true
            }
        }
        return false
    }
    
    //删除节点 双链表
    public func remove(node: ListNode) -> Int {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next // 1
        } else {
            head = next // 2
        }
        next?.previous = prev // 3
        
        if next == nil {
            tail = prev // 4
        }
        
        node.previous = nil
        node.next = nil
        
        return node.value
    }
    
    //删除链表中倒数第n个节点
    func removeNthFromEnd(head: ListNode?, _ n: Int) -> ListNode? {
        guard let head = head else {
            return nil
        }
        
        let dummy = ListNode(0)
        dummy.next = head
        var prev: ListNode? = dummy
        var post: ListNode? = dummy
        
        // 设置后一个节点初始位置
        for _ in 0 ..< n {
            if post == nil {
                break
            }
            post = post!.next
        }
        
        // 同时移动前后节点
        while post != nil && post!.next != nil {
            prev = prev!.next
            post = post!.next
        }
        
        // 删除节点
        prev!.next = prev!.next!.next
        
        return dummy.next
    }

}

extension ListTable {
    override public var description: String {
        var text = "["
        var node = head
        
        while node != nil {
            text += "\(node!.value)"
            node = node!.next
            if node != nil { text += ", " }
        }
        return text + "]"
    }
}
