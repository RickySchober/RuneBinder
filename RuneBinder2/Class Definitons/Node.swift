//
//  Node.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/14/25.
//

import Foundation

enum NodeType {
    case combat
    case shop
    case event
    case elite
    case rest
}

class MapNode: Identifiable, Equatable{
    var nextNodes: [MapNode]
    var position: Int
    var layer: Int
    var id = UUID()
    var icon = "combat"
    var selectable: Bool = false
    var type: NodeType?
    init(pos: Int = 1, lay: Int = 1, nodes: [MapNode] = [], tp: NodeType? = nil){
        position = pos
        nextNodes = nodes
        layer = lay
        type = tp
    }
    static func == (lhs: MapNode, rhs: MapNode) -> Bool {
            return lhs.id == rhs.id
    }
}
/*
class Combat: MapNode{
    override init(pos: Int = 1, lay: Int = 1, nodes: [MapNode] = []) {
        super.init(pos: pos, lay: lay, nodes: nodes)
        icon = "combat"
    }
}
class Shop: MapNode{
    override init(pos: Int = 1, lay: Int = 1, nodes: [MapNode] = []) {
        super.init(pos: pos, lay: lay, nodes: nodes)
        icon = "shop"
    }
}
class Event: MapNode{
    override init(pos: Int = 1, lay: Int = 1, nodes: [MapNode] = []) {
        super.init(pos: pos, lay: lay, nodes: nodes)
        icon = "event"
    }
}
class Start: MapNode{
    override init(pos: Int = 1, lay: Int = 1, nodes: [MapNode] = []) {
        super.init(pos: pos, lay: lay, nodes: nodes)
        icon = "start"
    }
}
*/
