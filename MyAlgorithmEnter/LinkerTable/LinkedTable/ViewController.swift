//
//  ViewController.swift
//  LinkedTable
//
//  Created by 姜泽东 on 2017/12/26.
//  Copyright © 2017年 MaiTian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let nodeList = ListTable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        nodeList.appendToTail(1)
        nodeList.appendToTail(5)
        nodeList.appendToTail(3)
        nodeList.appendToTail(2)
        nodeList.appendToTail(4)
        nodeList.appendToTail(2)
        
        //sgetLeftList(nodeList.head, 3)
        print(partition(nodeList.head, 3)!)
        print(nodeList.description)
        print(nodeList.head!.value,nodeList.tail!.value)
    }

    // 提取新链表的头节点
    func getLeftList(_ head: ListNode?, _ x: Int) -> ListNode? {
        let dummy = ListNode(0)
        var pre = dummy
        var node = head
        
        while node != nil {
            if node!.value < x {
                pre.next = node
                pre = node!
            }
            node = node!.next
        }
        return dummy.next
    }
    
    func partition(_ head: ListNode?, _ x: Int) -> ListNode? {
        // 引入Dummy节点
        let prevDummy = ListNode(0)
        var prev = prevDummy
        let postDummy = ListNode(0)
        var post = postDummy
        
        var node = head
        
        // 用尾插法处理左边和右边
        while node != nil {
            if node!.value < x {
                prev.next = node
                prev = node!
            } else { 
                post.next = node
                post = node!
            }
            node = node!.next
        }
        
        // 左右拼接
        post.next = nil
        prev.next = postDummy.next
        
        return prevDummy.next
    }
    
}

