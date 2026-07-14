# Material 3 Expressive component audit

Audit revision: 0.3.0
Audit basis date: 14 July 2026

The original prototype incorrectly treated “Material 3 enabled” as equivalent to “latest Material 3 Expressive.” This audit uses four explicit classifications:

- **Package-backed M3E** — a third-party implementation follows an M3E component model and is isolated behind a Motion-owned wrapper. This is not described as an official Flutter implementation.
- **M3E desktop adaptation** — an expressive primitive owns its state shape, hover, focus, press, selection, and disabled behavior while Motion adds desktop-specific composition.
- **Current Material 3** — the latest suitable official Flutter Material component is retained because it has stronger semantics or because no sufficiently complete M3E implementation is available.
- **Pending expressive work** — the present component is structurally sound but does not yet implement the relevant expressive shape, motion, or transformation model.

A package name containing “M3E” is not enough for an audit pass. Flutter’s core Material library does not yet provide the complete M3E set, so package-backed components remain replaceable and provisional.

## Component-by-component result

| Component family | Status | Current implementation | Decision and remaining work |
|---|---|---|---|
| Common action buttons | Package-backed M3E | `MotionActionButton` wraps `M3EButton` | Filled, tonal, elevated, outlined, and text hierarchy use centralized expressive sizes and spring-driven state-shape behavior. All shell surfaces use the wrapper rather than direct Flutter action buttons. |
| Icon buttons | Package-backed M3E | `MotionIconButton` wraps `IconButtonM3E` | Standard, filled, tonal, outlined, toggle, disabled, badge, tooltip, and minimum target behavior are centralized. XS–XL package sizing remains hidden behind Motion’s desktop size vocabulary. |
| Connected single-choice controls | Package-backed M3E | `MotionChoiceGroup` wraps `M3EToggleButtonGroup` | Replaces conventional `SegmentedButton` use for power profile, theme mode, and launcher layout. Connected-neighbor response and controlled selection are retained. |
| Split action/menu controls | Package-backed M3E | `MotionSplitButton` wraps `M3ESplitButton` | Used for audio endpoints: the primary segment toggles mute and the menu segment selects a device. Device names are display-only and IDs are validated by the service. |
| Continuous value sliders | **M3E desktop adaptation — provisional** | `MotionSlider` wraps Flutter’s official `Slider` | Output, input, and brightness use the current expressive default anatomy: 16 dp gapped track, 6 dp gap, narrow Material handle, value label, endpoint icons, keyboard behavior, and disabled states. Flutter still lacks the complete M3E API for XS–XL size presets, true inset-track icons, and native vertical orientation, so this row is deliberately not marked complete. |
| Quick-setting tiles | M3E desktop adaptation | `QuickSettingTile` composes `M3EToggleButton` | The expressive toggle owns selection shape, hover, focus, press, and checked motion. Motion adds two-line content and loading, error, unavailable, and service-state semantics. Loading, error, and unavailable tiles are non-actionable. |
| Indeterminate loading | Package-backed M3E | `LoadingIndicatorM3E` | Used only for short service transitions. Long operations must expose determinate progress or text rather than morph indefinitely. |
| Determinate OSD progress | Current Material 3 | `LinearProgressIndicator` with explicit current-M3 `ProgressIndicatorThemeData` | It communicates a value rather than loading, so replacing it with an indeterminate expressive loading indicator would be semantically incorrect. A dedicated M3E value track remains pending. |
| Search field | Current Material 3 / pending transformation | Flutter `SearchBar` | Keyboard entry, focus, clear action, semantics, and responsive width are strong. Expressive search-to-results container transformation and provider scopes are still missing. |
| Free-form text input | Current Material 3 | Flutter `TextField` and `InputDecoration` | Used for settings/search data entry where a button-like expressive control would be semantically wrong. Theme roles replace local hard-coded decoration. |
| Application and settings navigation | Current Material 3 / pending expressive navigation | `NavigationRail`, `NavigationBar` | Correct adaptive semantics and traversal are retained. Expressive indicator shapes, emphasized typography, destination motion, and rail/bar transitions require a dedicated adaptation and accessibility testing. |
| Top app bars | Current Material 3 / pending expressive app bar | Flutter `AppBar` | Settings uses the official app bar. The expressive app-bar variants and scroll transformations are not yet represented. |
| Desktop system toolbar | M3E mixed / pending toolbar choreography | Ambient bar plus `MotionIconButton` actions | Individual actions are expressive. Group expansion, clock/calendar transformation, active-app hierarchy, privacy choreography, and responsive overflow remain pending. |
| Cards and grouped surfaces | Current Material 3 | `Card.filled`, `Material`, surface color roles | Cards remain structural containers and are not treated as expressive merely because they have rounded corners. Hierarchy and shape come from shared tokens; container transformations remain pending. |
| Application tiles | Current Material 3 / pending expressive container | `Card.filled` + `InkWell` | Pointer, keyboard, tooltip, and ripple behavior are retained. Launch press-to-window continuity, shape morphing, selected state, and app actions need a dedicated expressive tile. |
| Workspace/window tiles | Current Material 3 / pending spatial component | Material cards and ink responses | The current overview preserves hierarchy and activation affordances. Live thumbnails, drag states, moving between workspaces, spatial continuity, and selection transformations remain pending. |
| Lists and preference rows | Current Material 3 | `ListTile` | Strong semantics, traversal, density, and text scaling are retained. Expressive list-entry motion may be layered without changing the list’s semantic role. |
| Preference switches | Current Material 3 | `Switch`, `SwitchListTile` | A persistent binary preference is a switch, not a toggle button. It is intentionally not replaced by `M3EToggleButton`. Any future visual update must retain switch semantics. |
| Menus and device choices | Package-backed split menu / current Material menu semantics | `MotionSplitButton` menu items | Audio devices are selected from endpoint-specific menus. Profile, port, and per-stream routing remain future detail surfaces rather than overloading this menu. |
| Dialogs | Current Material 3 / pending expressive motion | `AlertDialog`, `Dialog`, `showDialog` | Focus trapping, escape behavior, hierarchy, and secure action placement are retained. Container transforms and expressive enter/exit motion remain pending. |
| Modal sheets | Current Material 3 / pending expressive motion | `showModalBottomSheet` | Drag handle, focus, escape, and action hierarchy are correct. The session surface still needs expressive container motion and destructive confirmation choreography. |
| Notification dismissal | Current Material behavior | `Dismissible` around notification material | Gesture and keyboard dismissal behavior are preserved. Expressive arrival, group expansion, reflow, clear-all, media, and progress behavior depend on the notification broker. |
| Badges and privacy/status marks | Current Material 3 / pending choreography | Material icons, badge data, and semantic text | State never depends on color alone. Count transitions and privacy expansion remain pending. |
| Tooltips | Current Material 3 | Flutter `Tooltip` defaults with a shared wait time | The previous arbitrary shape/color override was removed. Compact ambient actions retain tooltips and semantic labels. |
| Focus and hover states | Mixed, centrally audited | Flutter focus system plus package-backed state layers | Direct interactive widgets must expose visible focus. Target-machine keyboard traversal and high-contrast verification remain acceptance gates. |
| Page and surface transitions | Pending expressive work | Shared `MotionTransitions` durations plus local `AnimatedSwitcher` | The legacy Linux fade-up transition override was removed. Shared-axis, container-transform, interruption, and reduced-motion variants still need a Motion transition layer. |
| Progress and activity states | Mixed | `LoadingIndicatorM3E` for activity; current-M3 progress for values | Loading and value progress are intentionally separated rather than chosen solely for visual novelty. |

## Surface audit

| Surface | Expressive components applied | Still current M3 or pending |
|---|---|---|
| System bar | Package-backed icon actions and toggles | Toolbar grouping motion, privacy expansion, active-app hierarchy, clock/calendar transform |
| Control center | Quick-setting adaptations, an official-Slider-based M3E desktop adaptation, split buttons, choice groups, actions, icon actions, and loading | Slider remains provisional until Flutter exposes XS–XL presets, inset icons, and native vertical orientation; sheet transition, device-detail pages, profiles/ports, and per-stream routing remain pending |
| Launcher | Package-backed icon actions and grid/list choice | Search treatment, application-tile transformation, selected/launch state, and app-action menu |
| Notifications | Package-backed actions and icon toggles | Live broker, arrival/grouping motion, media/progress layouts, and history choreography |
| Unified search | Package-backed supporting actions where present | Expressive search field/result transformation and provider navigation |
| Workspace overview | Package-backed primary actions | Live window materials, drag/move states, spatial continuity, and multi-monitor behavior |
| Settings | Package-backed actions, icon actions, and choice groups | Navigation, preference rows, app bars, dialogs, sheets, and section transitions remain current M3 |
| OSD | Current latest determinate progress | Expressive value track, interruption, and event coalescing |
| Session sheet | Package-backed actions | Expressive sheet transition and destructive confirmation flow |

## Audio control-center behavior

Output and input are independent domain objects and independent controls:

1. `wpctl status` is parsed into separate sink and source catalogs.
2. Monitor sources are excluded from the normal microphone list.
3. Each endpoint carries availability, selected device ID, devices, volume, and mute state.
4. The **Output** split control selects a sink; its primary segment mutes or unmutes that output.
5. The **Input** split control selects a source; its primary segment mutes or unmutes that microphone.
6. Each endpoint has its own slider and optimistic state; changing one cannot overwrite the other.
7. Sliders support 0–150 percent where PipeWire permits amplification and unmute the associated endpoint when adjusted.
8. The service validates numeric node IDs and verifies menu selections against the endpoint catalog before changing the default.
9. Missing WirePlumber, empty catalogs, malformed status output, and command failures become unavailable/error states; the controls are disabled instead of presenting fabricated success.

The current adapter uses WirePlumber’s `wpctl` command interface as a safe vertical-slice fallback. Event-driven PipeWire/WirePlumber object subscriptions remain the production target.

## Dependency and promotion policy

All third-party expressive components are hidden behind `Motion*` widgets. Shell surfaces do not import button or icon-button packages directly, and the slider is implemented on Flutter’s official `Slider` behind the same replaceable boundary. This allows replacement if Flutter’s standalone Material package gains an official implementation, a dependency becomes stale, or accessibility/performance validation fails.

A component can be promoted to “M3E complete” only after all of these pass:

- semantic role is correct for the task;
- controlled, disabled, loading, error, and unavailable states behave correctly;
- keyboard, pointer, focus, and scalable-text behavior pass on Linux;
- reduced-motion behavior is defined;
- theme roles are used without local hard-coded colors;
- target-machine analyzer, widget, integration, visual-regression, and frame-timing tests pass;
- its implementation matches the then-current M3E specification rather than an older package interpretation.

## Highest-priority remaining component work

1. Extend the provisional official-Slider adaptation when Flutter exposes verified XS–XL presets, inset-track icons, and native vertical orientation.
2. Build expressive shared-axis/container transitions with reduced-motion equivalents.
3. Prototype expressive navigation against rail/bar keyboard behavior and 200 percent text.
4. Implement expressive search/result container transformation rather than merely restyling `SearchBar`.
5. Add notification arrival, group expansion, and clear-all choreography after the broker exists.
6. Add determinate expressive OSD value tracks and event coalescing.
7. Run visual regression, focus traversal, Orca, high-contrast, scalable-text, memory, and animation-frame audits on the target system.
