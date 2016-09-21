//
//  GraphAdjacencyList.swift
//  Graph
//
//  Created by Mr.LuDashi on 16/9/19.
//  Copyright © 2016年 ZeluLi. All rights reserved.
//

import Foundation

class GraphAdjacencyListNote {
    var data: AnyObject
    var weightNumber: Int   //最小生成树使用
    var preNoteIndex: Int   //最小生成树使用, 记录该节点挂在那个链上
    
    var next: GraphAdjacencyListNote?
    var visited: Bool = false
    
    init(data: AnyObject = "", weightNumber: Int = 0, preNoteIndex: Int = 0) {
        self.data = data
        self.weightNumber = weightNumber
        self.preNoteIndex = preNoteIndex
    }
}

class GraphAdjacencyList: GraphType {
    private var graph: Array<GraphAdjacencyListNote>
    private var miniTree: Array<GraphAdjacencyListNote>
    private var relationDic: Dictionary<String,Int>
    private var bfsQueue: BFSQueue
    
    init() {
        graph = []
        relationDic = [:]
        bfsQueue = BFSQueue()
        miniTree = []
    }
    
    // MARK: - GraphType
    func createGraph(notes: Array<AnyObject>, relation: Array<(AnyObject,AnyObject,AnyObject)>){
        for i in 0..<notes.count {
            let note = GraphAdjacencyListNote(data: notes[i])
            graph.append(note)
            relationDic[notes[i] as! String] = i
        }
        
        for item in relation {
            guard let i = relationDic[item.0 as! String],
                j = relationDic[item.1 as! String] else {
                    continue
            }
            
            let weightNumber: Int = Int(item.2 as! NSNumber)
            let note2 = GraphAdjacencyListNote(data: j, weightNumber: weightNumber,preNoteIndex: i)
            note2.next = graph[i].next
            graph[i].next = note2
            
            let note1 = GraphAdjacencyListNote(data: i, weightNumber: weightNumber, preNoteIndex: j)
            note1.next = graph[j].next
            graph[j].next = note1
        }
    }
    
    func displayGraph() {
        displayGraph(graph)
    }
    
    func displayGraph(graph: Array<GraphAdjacencyListNote>) {
        for i in 0..<graph.count {
            print("(\(i))", separator: "", terminator: "")
            var cursor: GraphAdjacencyListNote? = graph[i]
            while cursor != nil {
                print("\(cursor!.data)(\(cursor!.weightNumber))", separator: "", terminator: "\t->  ")
                cursor = cursor?.next
            }
            print("nil")
        }
        print()
    }

    
    func breadthFirstSearch() {
        print("邻接链表：图的广度搜索（BFS）:")
        initVisited()
        breadthFirstSearch(0)
        print("\n")
    }
    
    func depthFirstSearch() {
        print("邻接链表：图的深度搜索（DFS）:")
        initVisited()
        depthFirstSearch(0)
        print("\n")
    }
    
    func breadthFirstSearchTree() {
        
    }
    
    
    func createMiniSpanTreePrim() {
        for i in 0..<graph.count {
            let note = GraphAdjacencyListNote(data: graph[i].data)
            miniTree.append(note)
        }
        
        createMiniSpanTreePrim(0, leafNotes: [], adjvex: [0])
        
        displayGraph(miniTree)
    }
    
    func createMiniSpanTreePrim(index: Int, leafNotes: Array<GraphAdjacencyListNote>, adjvex: Array<Int>)  {
        if adjvex.count != graph.count {
            
            var varLeafNotes = leafNotes
            
            
            //1、添加候选叶子节点
            var cousor = graph[index].next

            while cousor != nil {
                let cousorData: Int = Int((cousor?.data)! as! NSNumber)
                if !adjvex.contains(cousorData) && cousorData != 0 {
                    varLeafNotes.append(cousor)
                }
                cousor = cousor?.next
            }
            
            //2、寻找候选叶子节点中最小的权值，确定其能转正
            cousor = leafNotes.next
            var minLeafNode = cousor
            
            while cousor != nil {
                if minLeafNode?.weightNumber > cousor?.weightNumber {
                    minLeafNode = cousor
                }
                cousor = cousor?.next
            }
            print(minLeafNode?.data)
            
            //3、将这个最小的候选叶子节点添加到最小生成树中
            let preIndex = minLeafNode?.preNoteIndex
            let newLeafNote = GraphAdjacencyListNote(data: minLeafNode!.data, weightNumber: minLeafNode!.weightNumber, preNoteIndex: preIndex!)
            newLeafNote.next = miniTree[preIndex!].next
            miniTree[preIndex!].next = newLeafNote
            
            //4、将已经转正的叶子节点从候选叶子节点中删除
            let minLeafNoteData: Int = Int((minLeafNode?.data)! as! NSNumber)
            
            var preCousor = leafNotes.next!
            cousor = leafNotes.next
            while cousor != nil {
                let cousorData: Int = Int((cousor?.data)! as! NSNumber)
                if cousorData == minLeafNoteData {
                    let removeNote = cousor
                    removeNote?.next = nil
                    preCousor.next = cousor?.next
    
                }
                preCousor = cousor!
                cousor = cousor?.next
            }
            
            //5.记录下已转正的节点
            var tempAdjvex = adjvex
            tempAdjvex.append(minLeafNoteData)
            
            //6.递归下一个节点
            createMiniSpanTreePrim(minLeafNoteData, leafNotes: leafNotes, adjvex: tempAdjvex)
        }
    }
    
    private func breadthFirstSearch(index: Int) {
        
        //如果该节点未遍历，则输出该节点的值
        if graph[index].visited == false {
            graph[index].visited = true
            print(graph[index].data, separator: "", terminator: " ")
        }

        //遍历该节点所连的所有节点，并把遍历的节点入队列
        var cousor = graph[index].next
        while cousor != nil {
            let nextIndex: Int = Int((cousor?.data)! as! NSNumber)
            if graph[nextIndex].visited == false {
                
                graph[nextIndex].visited = true
                print(graph[nextIndex].data, separator: "", terminator: " ")
                bfsQueue.push(nextIndex)
            }
            cousor = cousor?.next
        }
        
        //递归遍历队列中的子图
        while !bfsQueue.queueIsEmpty() {
            breadthFirstSearch(bfsQueue.pop())
        }
    }

    
    private func depthFirstSearch(index: Int) {
        
        print(graph[index].data, separator: "", terminator: " ")
        graph[index].visited = true
        
        var cousor = graph[index].next
        while cousor != nil {
            let nextIndex: Int = Int((cousor?.data)! as! NSNumber)
            if graph[nextIndex].visited == false {
                
                depthFirstSearch(Int((cousor?.data)! as! NSNumber))
            }
            cousor = cousor?.next
        }
    }
    
    private func initVisited() {
        for item in graph {
            item.visited = false
        }
    }
}

