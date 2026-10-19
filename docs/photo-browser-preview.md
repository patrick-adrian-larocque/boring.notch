# Photo browser preview

This fork's first photo slice is an opt-in, read-only sample album browser. It is
intended to review the navigation before connecting Apple Photos.

## Try it

1. Build this branch using the repository's Xcode instructions.
2. In **Settings → Notch → Photos**, enable **Photo browser preview**.
3. Turn **Compact mode** off, open the notch, and choose its Photos icon.
4. Browse **All**, **Outdoors**, **Everyday**, and the empty **To organize** album.
5. Choose a sample item to see its details; use **Back** to return.
6. Disable the preview while viewing Photos; the notch returns to Home.

The symbols and titles are fixtures, not imported photos. The setting defaults
to off. There is no PhotoKit import, permission prompt, library scan, network
request, album write, export, or deletion in this implementation.

## Layers and boundaries

| Layer | Current implementation | Later work |
| --- | --- | --- |
| Library data | Immutable `PhotoLibrarySnapshot` with asset IDs and album memberships | A PhotoKit adapter that produces bounded snapshots |
| Navigation | `PhotoBrowserSelection` validates album and asset selections | Preserve valid selection when live snapshots change |
| Presentation | `PhotoBrowserView` accepts a snapshot; fixtures use SF Symbols | Cancellable thumbnail loading and authorization states |
| Host | Optional built-in tab in the existing expanded notch | Move behind an upstream destination descriptor when that API settles |
| Organization | No write operations | Separately decide whether grouping is app-local or writes Photos albums |

An asset can belong to multiple albums without duplicating the library asset.
Album lookup preserves snapshot order and ignores missing or repeated membership
references. Changing albums closes the previous item detail. Empty and unknown
albums return no items rather than accidentally exposing All.

The preview follows existing notch behavior: Compact mode shows the music player;
notifications can temporarily replace expanded content; Shelf's open-by-default
setting can select Shelf when the notch closes. The Photos switcher remains
reachable when Shelf or Always show tabs is disabled.

## Upstream extension status inspected on 2026-10-19

- [Extension manager #979](https://github.com/TheBoredTeam/boring.notch/pull/979)
  is closed without merging. Its discussion identifies rendering refactoring as
  a prerequisite, rather than a ready third-party extension contract.
- [Rendering refactor #1401](https://github.com/TheBoredTeam/boring.notch/pull/1401)
  is open and describes stable built-in destination descriptors. The maintainer
  also mentions a different version still in progress locally.

This preview does not import either PR or establish a competing plugin API.
Code changes are based on this fork's `dev` branch, per CONTRIBUTING.md. This is
a fork prototype, not an upstream contribution submission.

## Validation

`PhotoBrowserTests` exercises album membership, shared assets, empty and unknown
albums, detail navigation, invalid selections, and opt-in tab availability. Xcode discovers this test
through the existing synchronized `boringNotchTests` group. The two new app files
are explicitly registered in the app's Sources build phase.

This patch also supplies the missing shared `boringNotch` scheme with the app and
test targets. Its absence was reproduced on the unchanged base commit and made
the repository's existing product-name smoke test fail. The shared scheme lets
CI and the focused command below discover the tests consistently.

Run the repository's build and test workflow on macOS, or locally:

```sh
xcodebuild -project boringNotch.xcodeproj -scheme boringNotch \
  -configuration Debug -destination 'platform=macOS' \
  -only-testing:boringNotchTests/PhotoBrowserTests test
```

Manual macOS acceptance remains necessary: tab spacing, scrolling and details in
the 640 × 190 notch, keyboard/VoiceOver navigation, toggling off while selected,
Shelf-disabled and Always-show-tabs-disabled combinations, compact mode, and
notification interruption. Do not call the preview runtime-verified until those
checks pass.

Before connecting real Photos, decide authorization and limited-access behavior,
snapshot bounds, iCloud thumbnail policy, cancellation and observer lifecycle.
Keep album mutations as a separate feature with explicit user intent.
