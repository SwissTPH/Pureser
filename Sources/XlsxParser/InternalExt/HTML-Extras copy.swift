//
//  File.swift
//  
//
//  Created by R. Makhoul on 10/11/2020.
//

import Foundation

//--------------------------------------------------

import Swim

public func nodeContainer(
	@NodeBuilder children: () -> NodeConvertible = { Node.fragment([]) }
) -> Node {
	return children().asNode()
}

extension Node {
	public func renderAsString() -> String {
		return String(describing: self)
	}
}

//--------------------------------------------------
