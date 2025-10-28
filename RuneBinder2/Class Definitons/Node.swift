//
//  Node.swift
//  RuneBinder2
//
//  Created by Ricky Schober on 5/14/25.
//

import Foundation

enum NodeType: String, Codable {
    case combat, shop, elite, event, rest
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
extension MapNode {
    func toData() -> MapNodeData {
        MapNodeData(
            id: self.id,
            position: self.position,
            layer: self.layer,
            icon: self.icon,
            selectable: self.selectable,
            type: self.type,
            nextNodeIDs: self.nextNodes.map { $0.id }
        )
    }

    // first pass: create nodes without links
    static func fromDataArray(_ datas: [MapNodeData]) -> [UUID: MapNode] {
        var nodes: [UUID: MapNode] = [:]
        for data in datas {
            let node = MapNode(pos: data.position,
                               lay: data.layer,
                               nodes: [],
                               tp: data.type)
            node.id = data.id
            node.icon = data.icon
            node.selectable = data.selectable
            nodes[data.id] = node
        }
        // second pass: rebuild edges
        for data in datas {
            if let node = nodes[data.id] {
                node.nextNodes = data.nextNodeIDs.compactMap { nodes[$0] }
            }
        }
        return nodes
    }
}
