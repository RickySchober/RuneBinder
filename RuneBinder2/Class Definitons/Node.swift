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
