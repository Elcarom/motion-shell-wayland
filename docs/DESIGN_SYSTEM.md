# Motion visual system

## Direction

Motion uses Material 3 as the only component and interaction grammar. Expressiveness comes from state-responsive shape, meaningful scale, bolder hierarchy, and spatial motion—not blur, neon, transparency, random gradients, or a row of unrelated rounded modules.

The default personality is calm and optimistic: large readable headings, broad tonal surfaces, asymmetric emphasis where hierarchy benefits, and restrained elevated surfaces. The system bar is a single ambient material with grouped entry points rather than a collection of widgets.

## Color architecture

### Pipeline

1. Read the active wallpaper once when its path or file identity changes.
2. Decode and downsample to a bounded sample.
3. Ignore mostly transparent pixels.
4. Quantize with Material Color Utilities' Celebi quantizer.
5. Score candidates with population and suitability rules.
6. Choose a stable seed and retain alternatives for user override.
7. Generate light and dark `ColorScheme` instances from the seed.
8. Validate foreground/background role pairs; fall back to the canonical purple seed when decoding or scoring fails.
9. Persist the source fingerprint and palette; invalidate when path, modified time, size, or contrast preference changes.
10. Publish the theme revision through the state service so every process transitions together.

The code implements steps 1–7 and fallback behavior. Fingerprint caching and cross-process animated revisions are the next integration increment.

### Roles

- `surface` is the desktop app canvas.
- `surfaceContainer` is the primary shell material.
- `surfaceContainerHighest` is an unselected control or nested region.
- `primaryContainer` marks dominant selection or current spatial context.
- `secondaryContainer` supports selected quick settings and lower-emphasis actions.
- `tertiaryContainer` distinguishes app identity and optional content.
- `errorContainer` is reserved for destructive or failed states.
- `outlineVariant` separates materials without introducing arbitrary borders.

No component owns a hard-coded brand color. The only hard-coded color is the documented fallback seed.

## Light example

- Warm or chromatic wallpaper seed produces a bright neutral canvas.
- System surfaces remain slightly tonal rather than pure white.
- Selected workspace and active quick setting use container roles with strong on-container text.
- Shadows are low and reserved for overlays that cross hierarchy.

## Dark example

- Dark surfaces are tonal, not black glass.
- Containers establish depth by role, not opacity stacking.
- Bright container roles communicate selection without neon saturation.
- Outlines remain visible for keyboard focus and unavailable states.

## Typography

Roboto is the primary UI family because it aligns with Material's typographic character and is packaged on Arch. Roboto Mono is used only for diagnostics, identifiers, and command output.

- Display/large headline: onboarding and empty-state moments.
- Headline small: surface title.
- Title medium: control group or card title.
- Body medium: descriptions and notification content.
- Label large: controls and ambient bar identity.
- Label medium/small: metadata and status.

Text scaling is not clamped globally. Surfaces scroll or adapt when scale increases.

## Shape system

| Token | Radius | Use |
|---|---:|---|
| Small | 12 | chips, compact status, nested focus |
| Medium | 20 | list rows, low-emphasis controls |
| Large | 28 | tiles, cards, app cells |
| Extra large | 36 | shell overlays and dialogs |
| Full | Stadium | bar and single-line high-emphasis actions |

Quick-setting tiles use the expressive toggle shape family: unchecked surfaces remain rounder while checked surfaces become more squared. The interaction is owned by `M3EToggleButton`; Motion only adapts its content for desktop service state.

## Spacing and density

- Base rhythm: 4 px.
- Common gaps: 8, 12, 16, 20, 24, 28, 36.
- Default interactive target: 48 px.
- Compact target is 40 px only for dense ambient surfaces with tooltips and keyboard access.
- Overlay padding: 20 px minimum.

Desktop width is used for hierarchy and multiple columns, never to shrink controls below accessible size.

## Elevation

- Level 0: app canvas and content regions.
- Level 1: selected or nested tonal containers.
- Level 2: resident bar.
- Level 3: transient overlay and modal sheet.
- Higher levels are avoided unless a blocking dialog requires them.

Elevation is expressed with Material surface roles and minimal shadow. Blur is not a structural tool.

## Icons

Flutter Material Symbols are used for shell actions and state. Third-party app icons come from XDG icon lookup in the full implementation; the foundation safely falls back to an initial/avatar when icon resolution fails. Icon sizes are 20–24 for controls, 28–36 for prominent status, and 48+ only for empty states.

## Motion tokens

| Token | Duration | Purpose |
|---|---:|---|
| Instant | 90 ms | pressed and tiny state response |
| Short | 180 ms | toggle, chip, local selection |
| Medium | 320 ms | surface content transition |
| Long | 520 ms | spatial overview and shared-axis movement |

Curves use emphasized acceleration/deceleration and are centralized in `MotionTransitions`. Reduced motion resolves durations to zero and replaces spatial travel with direct state changes.

### Motion behaviors

- Bar entry points expand into their destination region rather than fading from nowhere.
- Launcher results use shared-axis or container transforms tied to the search field.
- Workspace movement follows the user's requested spatial direction.
- Notification arrival expands from the popup lane; dismissal compresses adjacent content.
- Theme changes cross-fade role colors once all processes acknowledge the revision.
- OSDs enter, update in place, and exit without focus or layout interruption.

## Component mapping

| Need | Selected implementation | Classification | Desktop adaptation |
|---|---|---|---|
| Action hierarchy | `MotionActionButton` → `M3EButton` | Package-backed M3E | Central variants and sizes |
| Compact/system actions | `MotionIconButton` → `IconButtonM3E` | Package-backed M3E | Tooltips, badges, toggled state |
| Connected choice | `MotionChoiceGroup` → `M3EToggleButtonGroup` | Package-backed M3E | Power profile, theme, launcher layout |
| Compound action + menu | `MotionSplitButton` → `M3ESplitButton` | Package-backed M3E | Audio mute plus source selection |
| Continuous value | `MotionSlider` → Flutter `Slider` | M3E desktop adaptation, provisional | 16 dp gapped track, 6 dp gap, narrow handle, endpoint icons, percent label, 150% audio range; pending XS–XL/inset-icon/vertical API |
| Quick toggle | `QuickSettingTile` → `M3EToggleButton` | M3E desktop adaptation | Two-line service label and availability states |
| Short loading | `LoadingIndicatorM3E` | Package-backed M3E | Service-state semantic label |
| App/settings navigation | `NavigationRail`, `NavigationBar` | Current M3 | Adaptive by width; expressive replacement pending |
| Search | `SearchBar`, list hierarchy | Current M3 | Unified source badges and keyboard selection |
| Binary preference | `SwitchListTile`, `Switch` | Current M3 | Retains preference semantics |
| Notifications | `Card.filled`, `Dismissible`, M3E actions | Mixed | Grouping and urgency model |
| Dialog/sheet | `Dialog`, `showModalBottomSheet` | Current M3 | Desktop width constraints; expressive motion pending |
| Determinate progress | `LinearProgressIndicator` with explicit current-M3 `ProgressIndicatorThemeData` | Current M3 | OSD value, not loading |
| Settings rows | `ListTile`, `SwitchListTile` | Current M3 | Rounded focus region |

See [`M3E_COMPONENT_AUDIT.md`](M3E_COMPONENT_AUDIT.md) for the full widget and surface audit.

## Component audit rule

Every new control must answer: official widget availability, semantic correctness, state completeness, token use, motion purpose, responsive behavior, keyboard/focus behavior, and whether it copied a conventional desktop pattern without necessity.
