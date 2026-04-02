# Superboard Clipboard App Design

## Overview

Superboard is a clipboard app that treats clipboard history as the primary product surface and cloud collaboration as the expansion path. The first shipped version targets macOS and focuses on replacing the default paste flow with a smarter history-driven flow: the user copies as usual with `Cmd+C`, then presses `Cmd+Shift+V` to open a lightweight picker near the current input context, selects one of the recent items, and the app immediately pastes it into the focused application.

The long-term product direction is cross-platform support for both macOS and Windows. The initial implementation may be macOS-only, but the architecture must preserve a clean path to a Windows version without rewriting the product core. The design therefore separates platform-specific OS integration from shared product logic such as history ordering, workspace semantics, and future sync models.

## Product Goals

### Primary goals

- Capture normal system copy operations for text, images, and files.
- Replace default paste selection with a history-aware picker triggered by `Cmd+Shift+V`.
- Keep the paste flow fast and low-friction so the user feels they are still in the original input context.
- Provide a menubar app for management, status, and future workspace controls.
- Preserve a clean upgrade path to cloud-backed personal workspaces and shared workspaces.

### Success criteria for V1

- On macOS, the app reliably detects copy events for text, image, and file clipboard payloads.
- The app stores clipboard history locally and shows the latest 10 items by default, with the limit configurable later.
- Pressing `Cmd+Shift+V` opens a picker near the active input context rather than forcing a full app switch.
- Choosing an item immediately pastes it into the currently focused application.
- The product is stable enough to use as a real replacement for repetitive copy/paste tasks.

### Non-goals for V1

- No cloud sync implementation yet.
- No account system for local-only use.
- No shared workspace collaboration flow in the first shipped version.
- No advanced content editing, annotation, or knowledge-base behavior.
- No attempt to fully solve perfect per-app caret anchoring if that would delay core reliability.

## Core User Experience

### Primary paste flow

1. The user copies any supported content through normal system copy behavior.
2. Superboard detects the clipboard change and stores a new history item in the active local workspace.
3. The user presses `Cmd+Shift+V` while typing or editing.
4. Superboard opens a compact picker near the active input context.
5. The picker shows recent history items in reverse chronological order with type-specific previews.
6. The user navigates with keyboard controls and selects one item.
7. Superboard restores that payload to the system clipboard and immediately performs paste into the focused app.

### Management flow

- The menubar app is the control surface for settings, history browsing, diagnostics, and future workspace status.
- Workspace switching in V1 should be possible from the menubar and via a dedicated global shortcut.
- The picker is not the place for workspace management in the first version. It should remain focused on fast selection and paste.

### UX principles

- The product should feel like an upgrade to paste, not a separate destination app.
- The picker should appear close enough to the active editing context to preserve focus and momentum.
- Opening, navigation, and paste execution should favor consistency over visual complexity.
- The default interaction model should be keyboard-first.

## Platform Strategy

### Recommended approach

Use a shared product core with platform-specific OS integration layers.

This means the first implementation is a macOS-native app, but the architecture is split so that history rules, workspace semantics, and future sync behavior can be reused. Platform-specific code remains responsible for clipboard access, global shortcuts, picker placement, and immediate paste execution.

### Why this approach

- A clipboard product is dominated by OS integration quality, not generic app shell concerns.
- A pure cross-platform shell too early would increase risk around shortcut handling, input-context placement, and reliable paste restoration.
- A fully native-per-platform approach would maximize quality but would duplicate too much product logic and slow the Windows path.
- Shared core plus native integration preserves product quality while keeping expansion realistic.

## System Architecture

### Major modules

#### 1. Clipboard Watcher

Observes system clipboard changes and translates native pasteboard payloads into normalized internal items. It must support text, images, and file references. It is responsible for deduplication signals such as content fingerprints and capture timestamps but not for product-level ranking decisions.

#### 2. History Store

Stores clipboard items locally, enforces retention rules, and serves recent items to the picker. This layer owns the canonical local model for clipboard history and later becomes the source that sync pipelines read from.

#### 3. Paste Picker

Displays recent items near the active editing context when the global paste-history shortcut is pressed. It is optimized for low-latency rendering, compact previews, and keyboard-first navigation.

#### 4. Paste Executor

Takes a selected history item, restores it to the system clipboard in the correct native format, and triggers immediate paste into the currently focused application. This module is the key reliability boundary for making the app feel seamless.

#### 5. Workspace Manager

Tracks the active workspace and exposes a stable interface for future expansion from local-only mode to personal cloud workspaces and shared workspaces. V1 uses a default local workspace but keeps workspace identity in the model from day one.

#### 6. Menubar App Shell

Hosts settings, status, history browsing, diagnostics, onboarding, and future login or workspace surfaces. It is not the main interaction loop for frequent paste behavior.

### Layer separation

#### Shared core

- Clipboard item model
- History ordering and retention
- Workspace identity and activation rules
- Sync eligibility flags and future sync contracts
- Search and filtering rules

#### Platform layer

- Clipboard observation
- Global shortcut registration
- Picker anchoring and positioning
- Accessibility or automation hooks needed for immediate paste
- Native content restoration for text, images, and files

This boundary is mandatory so that Windows can reuse the product core later.

## Data Model

### Clipboard item

The core unit is `ClipboardItem`.

Suggested fields:

- `id`
- `workspaceId`
- `capturedAt`
- `sourceAppId`
- `sourceAppName`
- `contentType` with values such as `text`, `image`, `file`
- `previewText`
- `storageRef`
- `fingerprint`
- `isSensitive`
- `syncState`
- `metadata`

### Content storage model

- Text items store the original text plus a preview-safe shortened representation.
- Image items store the original binary asset plus metadata such as dimensions and an optional thumbnail.
- File items store one or more file references and enough metadata to rebuild a valid file paste payload.

### Workspace model

The system should treat every item as belonging to a workspace, even in V1. The initial app ships with a default local workspace. Future expansions can add:

- Personal cloud workspace
- Shared workspace with invited collaborators

The point of this abstraction is to avoid a local-only schema that later has to be rewritten when sync arrives.

## Security and Privacy

### Recommended policy

Default to local-first storage, opt-in cloud sync, and sensitive-content exclusion by default.

### Policy details

- Local-only use does not require login.
- Clipboard items are never uploaded automatically in V1 because no cloud feature ships yet.
- When cloud workspaces are introduced, only items belonging to a cloud-enabled active workspace should be eligible for sync.
- Sensitive apps and high-risk contexts should be excluded by default from sync eligibility.
- The product should preserve user trust by making data movement predictable and explicit.

### Sensitive-content strategy

The product should support a default exclusion list for security-sensitive application categories such as password managers and authentication surfaces. It may also mark likely sensitive items through heuristics, but heuristics should not be treated as the sole protection layer. The primary protection is conservative sync policy plus explicit workspace intent.

## Cloud Expansion Boundary

Cloud is not built in V1, but V1 must leave room for it.

### Future capabilities to enable

- Personal multi-device clipboard sync
- Shared team workspaces
- Membership and permissions
- Device identity
- Per-item sync state
- Conflict handling for replicated history streams

### V1 design requirement

Define interfaces and model fields so that sync can be added without changing the local interaction model or rewriting history storage semantics. The first version does not need backend implementation, but it must avoid assumptions that only make sense in a permanently offline app.

## Reliability Constraints

### Picker placement

The intended UX is that the picker appears above or near the current input area, similar to a context-local select box. In practice, exact caret-relative placement across all macOS apps may not be consistently available. V1 should therefore target contextual placement near the active editing area or focused window while optimizing for perceived continuity rather than perfect geometric precision.

### Immediate paste

Immediate paste after selection is mandatory for V1. The app should restore the chosen native payload and then trigger paste with minimal delay. This path must be tested carefully across target applications because it is the main determinant of whether the product feels trustworthy.

### Supported clipboard types

V1 must support system copy behavior for:

- Text
- Images
- Files

If a copied payload contains mixed or unsupported types, the app should degrade predictably rather than silently corrupting the paste result.

## Testing Strategy

### Core verification areas

- Clipboard capture for text, image, and file payloads
- History ordering and deduplication behavior
- Picker open latency and keyboard navigation
- Immediate paste success across representative apps
- Stability of menubar controls and shortcut registration

### Test mix

- Unit tests for shared core logic such as history ordering, retention, deduplication rules, and workspace semantics
- Integration tests for native clipboard conversion boundaries where feasible
- Manual verification matrix for real-world macOS apps because clipboard and focus behavior depend on OS integration

### Minimum manual validation targets

- Native text inputs
- Browsers
- Document editors
- Design or creative tools that use image clipboard payloads
- File manager scenarios for copied files

## Phased Delivery

### Phase 1: Local macOS MVP

- Menubar app shell
- Clipboard watcher
- Local history store
- Picker UI for recent items
- Immediate paste execution
- Support for text, images, and files

### Phase 2: Workspace foundations

- Active workspace switching in menubar
- Global shortcut for workspace switching
- UI states that make workspace identity visible

### Phase 3: Cloud expansion

- Optional login
- Personal multi-device sync
- Shared workspace creation and membership

## Risks and Mitigations

### Risk: OS integration complexity is higher than generic app complexity

Mitigation: keep the first release macOS-native and isolate platform code behind stable interfaces.

### Risk: caret-accurate positioning is inconsistent across apps

Mitigation: optimize for “near the active input context” rather than a strict caret contract in V1.

### Risk: immediate paste behavior varies by target app

Mitigation: define an explicit manual app compatibility matrix and treat paste reliability as a release gate.

### Risk: cloud sync later introduces privacy trust issues

Mitigation: preserve local-first defaults and keep cloud as explicit workspace-driven behavior.

## Recommendation Summary

Build the first version as a macOS-native menubar clipboard app with a keyboard-first paste-history picker, immediate paste execution, and robust support for text, images, and files. Structure the app so shared core logic survives the later Windows build and future cloud workspaces without forcing a redesign of the local user experience.
