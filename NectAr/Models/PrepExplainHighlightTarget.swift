//
//  PrepExplainHighlightTarget.swift
//  NectAr
//

import Foundation

/// Which preparation-phase UI element a narration step should call out, if any.
enum PrepExplainHighlightTarget {
    case deviceSelector
    case actionButton
    /// Just the Router icon within the device list, not the whole list.
    case routerOnly
}
