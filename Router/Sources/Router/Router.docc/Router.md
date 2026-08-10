# ``Router``

3D assets for NectAr: the Router model and the mail-packet model, authored in Reality
Composer Pro and packaged as a local Swift package so the app can `import Router`.

## Overview

This package has no logic — it exists to bundle `Router.usdz`/`.usda` and
`mail.usda`/`.usdz` (see `Sources/Router/Router.rkassets/`) and expose them via
``routerBundle``. `DeviceEntityLoader` in the NectAr app target is the only consumer;
it loads entities by name (`"Router"`, `"mail"`) from this bundle.

If you need to change the 3D content itself, edit `Router.rkassets` through Reality
Composer Pro — don't hand-edit the `.usda` files, they're generated/managed by the
tool.

## Topics

### Bundle access

- ``routerBundle``
