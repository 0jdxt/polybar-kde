# polybar-kdeconnect

[KDEConnect](https://github.com/KDE/kdeconnect-kde) module for [Polybar](https://github.com/jaagr/polybar)

![bar](bar.png)

![menu](menu.png)
![pmenu](pmenu.png)

Demo with:

* [Nord Theme](https://nordtheme.com) polybar
* [Blex Mono Nerd Font](https://www.nerdfonts.com/)
* custom [dmenu](https://github.com/0jdxt/dmenu)

## Dependencies

* [dmenu](https://tools.suckless.org/dmenu)
* [kdeconnect](https://github.com/KDE/kdeconnect-kde)
* A Nerd Font
* [Zenity](https://github.com/GNOME/zenity)
* qbus-qt5 (or qt5tools on some distros)

## Usage

Place the given script in some folder, and use it in your polybar `config` as

```
[module/kdeconnect]
type = custom/script
exec = "/path/to/files/polybar-kdeconnect.sh -d"
tail = true
````

## Customization

You can change the variables in [`polybar-kdeconnect.sh`](polybar-kdeconnect.sh)
to customize the [rofi](https://github.com/DaveDavenport/rofi) menu and
the icons shown in [polybar](https://github.com/jaagr/polybar)

## Default Color Code Legend

Color | Meaning |
---|---|
![Disconnected](https://via.placeholder.com/16.png/434C5E/434C5E) | Device Disconnected |
![New Device](https://via.placeholder.com/16.png/8FBCBB/8FBCBB) | Unpaired Device |
![Baterry_90](https://via.placeholder.com/16.png/88C0D0/88C0D0) | Battery >= 90 |
![Baterry_80](https://via.placeholder.com/16.png/81A1C1/81A1C1) | Battery >= 80 |
![Baterry_70](https://via.placeholder.com/16.png/5E81AC/5E81AC) | Battery >= 70 |
![Baterry_60](https://via.placeholder.com/16.png/EBCB8B/EBCB8B) | Battery >= 60 |
![Baterry_50](https://via.placeholder.com/16.png/D08770/D08770) | Battery >= 50 |
![Baterry_LOW](https://via.placeholder.com/16.png/BF616A/BF616A) | Battery < 50 |

## Changelog

### v2

* Supports Multiple Devices without extra configuration
* Supports pairing/unpairing devices
* Removed `kdeconnect-cli` as dependency
* Combined seperate files into one
* Seperate icons for tablets and smartphone
