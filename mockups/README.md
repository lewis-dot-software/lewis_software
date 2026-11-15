---
type: knowledge
aliases: design, mockups, the look, design language
---

# Mockups

The site's look, as Dan ruled it in the design sitting on the home page. The canvas is [lewis-software-home-page](lewis-software-home-page/canvas.json), and candidate D, Imprint, is the design the site builds.

| Artboard | Shows |
|---|---|
| [Home, dark](lewis-software-home-page/Imprint.png) | The home page in Mocha, the common case |
| [Home, light](lewis-software-home-page/ImprintLatte.png) | The same page in Latte |
| [Home at phone width](lewis-software-home-page/ImprintPhone.png) | The same page at 390px |
| [404](lewis-software-home-page/NotFound.png) | The page a missing path shows |

The other candidates stay on the canvas for reference, and none of them is built.

## Language

- Publisher first: the `lewis.software` wordmark leads, its dot in the accent, and Dan is named once, in the footer.
- Palette: Catppuccin, Mocha for dark and Latte for light. The page follows the reader's system theme, and a toggle overrides it.
- Accent: mauve, for links, the wordmark's dot and the headline's full stop.
- Products: each takes one Catppuccin accent of its own, grit peach and muster teal. In dark, its name is set in that colour under a rule of it. In light, its name takes the text colour and keeps the rule, since Latte's lighter accents fail contrast as text.
- Product names in running text: a tag in the product's colour, its accent at low opacity behind the name.
- Type: the system font stack alone, so the site serves no font files.
- Always and never: a `+` in teal marks Always, and a `−` in peach marks Never.
- Layout: one column of at most 72rem, with full-width bands for contrast. At phone width every grid stacks to one column.
- Tools: a section of its own now. It becomes a collapsible section beside an Apps section once the first app is published.
- Nothing decorative: no gradients, icons, cards with shadows or emoji.

## Copy

The words on the home and 404 artboards stand as Dan edited them, the always and never lists word for word.
