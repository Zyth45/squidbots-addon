# SquidBots Lite

A World of Warcraft 3.3.5 addon for [CoA Bots](https://github.com/Zyth45/mod-playerbots): your bots, without a window in the way.

No window. A thin bar of six buttons, the bots' roles drawn straight onto the party frames you already have, and offers arriving as small toasts.

## The bar

Five orders, one click each: **Follow**, **Stay**, **Attack my target**, **Passive**, **Dungeon**. Dungeon mode keeps bots with you, out of the stuff on the ground, and pulling when you pull.

Right-click the bar for profiles: **Farm** (hunt, loot, eat), **Strict follow**, **Dungeon**. Shift-drag a button to move the bar.

## Asking for bots

The sixth button asks for a **tank**, a **healer**, **damage**, or all three. It types `lfg bot` in your Zone or Newcomers channel, exactly as you would. Free bots answer with an offer, shown as a toast above the bar with an **Invite** button.

GMs can switch to `.playerbots coa` with `/sbl gm` and skip the channel.

## On your party frames

Each bot gets a role icon on its frame. Click it for that bot alone: come to me, stay here, attack my target, auto pull on or off, remove from group. The frames also show **Low mana**, **Pulling** and **Rez** without a word of chat.

## Commands

```
/sbl                 show or hide the bar
/sbl lang fr | en    French or English
/sbl channel <name>  ask in a different channel (a name, not a number)
/sbl gm              GM mode
/sbl reset           put the bar back in the middle
```

## Install

It ships with CoA Bots v1.4, whose installer copies it into your client. To install it by hand, copy the `SquidBotsLite` folder into `Interface/AddOns`.

Everything it sends is a chat command mod-playerbots already understands: it never asks the server for anything a player could not type.

## Related

- [mod-playerbots, CoA Bots branch](https://github.com/Zyth45/mod-playerbots)
- [SquidBots dashboard](https://github.com/Zyth45/squidbots-dashboard)

## License

GPL-2.0, see [LICENSE](LICENSE).
