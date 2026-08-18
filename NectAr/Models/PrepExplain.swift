//
//  PrepExplainText.swift
//  NectAr
//
//  Created by abr on 14/08/26.
//

import Foundation

struct PrepExplain: Identifiable {
    /// Advances narration to `next`, either automatically after `duration` (nil
    /// means no timer) or immediately if the card is tapped and `canAdvanceNow`
    /// allows it. A step with no `Advance` at all only ever advances through an
    /// explicit external `step(to:)` call, e.g. a real placement condition.
    struct Advance {
        let next: String
        let duration: TimeInterval?
        let canAdvanceNow: Bool
    }

    let id: String
    let description: String
    let cardStyle: PrepExplainCardStyle
    let highlightTarget: PrepExplainHighlightTarget?
    /// Device list and action button aren't rendered at all.
    let hidesPlacementUI: Bool
    /// Device list and action button are visible but both disabled, no dimming.
    let locksPlacementUI: Bool
    /// A translucent layer dims the camera view, the component matching
    /// `highlightTarget` stays enabled and highlighted, everything else in the
    /// placement UI is dimmed and disabled.
    let usesSpotlightOverlay: Bool
    /// Router stays locked out of the device list until its own dedicated step.
    let excludesRouterFromSelection: Bool
    /// Whether this step is suppressed once the user skips the guided tutorial.
    let suppressedWhenSkipped: Bool
    let advance: Advance?

    init(
        id: String,
        description: String,
        cardStyle: PrepExplainCardStyle = .prepExplainCard,
        highlightTarget: PrepExplainHighlightTarget? = nil,
        hidesPlacementUI: Bool = false,
        locksPlacementUI: Bool = false,
        usesSpotlightOverlay: Bool = false,
        excludesRouterFromSelection: Bool = false,
        suppressedWhenSkipped: Bool = false,
        advance: Advance? = nil
    ) {
        self.id = id
        self.description = description
        self.cardStyle = cardStyle
        self.highlightTarget = highlightTarget
        self.hidesPlacementUI = hidesPlacementUI
        self.locksPlacementUI = locksPlacementUI
        self.usesSpotlightOverlay = usesSpotlightOverlay
        self.excludesRouterFromSelection = excludesRouterFromSelection
        self.suppressedWhenSkipped = suppressedWhenSkipped
        self.advance = advance
    }
}
