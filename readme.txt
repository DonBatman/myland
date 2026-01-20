# 🗺️ MyLand
A robust and intuitive land protection system for **Luanti**.
Part of the **"My" Mod Suite**.

MyLand allows players to claim territory and manage permissions with ease. Designed for both small servers and large survival hubs, it ensures your builds remain yours.

---

## ✨ Features
* **Visual Borders:** Easily see your claim boundaries with temporary grid markers.
* **Member Management:** Add friends to your land with specific roles (Guest, Builder, Admin).
* **Area Protection:** Prevents griefing, fire spread, and unauthorized TNT usage.
* **Automatic Expiry:** (Optional) Clears old claims from inactive players to keep the map fresh.
* **Performance First:** Uses spatial hashing to check protections instantly without server lag.

---

## 🛠️ Installation
1. Place the `myland` folder into your `mods/` directory.
2. Ensure the folder is named `myland`.

---

## ⚙️ Configuration
| Setting | Default | Description |
| :--- | :--- | :--- |
| `myland_max_claims` | 5 | Max number of areas a player can own. |
| `myland_max_size` | 50 | The maximum radius of a single claim. |
| `myland_protection_style` | radius | Choose between 'radius' or 'box' protection. |

---

## 📜 License
MIT
