# Custom QBCore Inventory UI

This repository provides a custom modern UI design intended to replace or inspire modifications to the default `qb-inventory` frontend.

It features:
- A modern dark theme with blur and semi-transparent panels.
- Drag and drop item management using jQuery UI.
- Integrated search and categorised filtering.
- Specific equipment slots (hat, mask, vest, etc.) surrounding a central ped view area.

## ⚠️ Important Note regarding Backend Logic

The Lua files provided in this repository (`client/main.lua` and `server/main.lua`) are **skeleton placeholders** used for UI testing. They do **not** contain the complex backend logic required to manage items, weights, drops, and stashes on a live server.

### How to use this project:
To implement this in a live FiveM server, you should **replace the HTML folder** of your existing `qb-inventory` script with the `html` folder provided here, and adapt the `app.js` event listeners to match the specific NUI callbacks expected by your version of `qb-inventory`.

Do not replace your `server/main.lua` with the one provided here, as it will break inventory functionality.