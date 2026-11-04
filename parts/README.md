# Parts

The things we buy, and where. Two sheets, so a part keeps its identity while the places to buy
it come and go: an Amazon listing today, a Farnell order code when the same thing is sourced
properly. Each component's catalogue page shows its rows as "Where to buy".

## parts.csv: one row per buyable thing

| Column | |
|---|---|
| `id` | Short, stable, lower-case. Project BOMs refer to this |
| `name` | What you'd call it |
| `category` | board, module, connector, sensor, magnet, battery, switch, led, fixing |
| `manufacturer` | Who makes it, if there is one. Blank for generic designs with many sellers |
| `mpn` | The manufacturer's part number, the thing a distributor can look up. Blank means it has to be re-sourced by description and checked with the fit piece |
| `component` | The library component it fits (`components/<id>`) |
| `notes` | Anything the buyer should know |

## sources.csv: one row per place to buy it

| Column | |
|---|---|
| `part` | `parts.csv` id |
| `supplier` | Amazon UK, The Pi Hut, Farnell, RS, Mouser, DFRobot… Blank: in hand, listing not recorded |
| `sku` | The supplier's number: ASIN, Pi Hut SKU, Farnell order code |
| `url` | Straight to the listing |
| `price`, `currency` | As seen on `date`. Unit price, before VAT and postage |
| `date` | When this row was last checked |
| `notes` | Pack size, which variant, what arrived |

Add a row rather than editing one when a supplier changes: the old row says what was bought.
