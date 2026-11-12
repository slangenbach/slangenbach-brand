# slangenbach-brand

Stefan Langenbach's brand (colours and fonts) as a [Quarto][quarto] brand
extension, shared by [stefan.langenbach.online][site] and his personal
slide decks. The brand is defined in the [brand.yml][brand-yml] format in
[`_extensions/slangenbach/brand.yml`](_extensions/slangenbach/brand.yml).

The brand holds only what applies to every medium: colours and fonts.
Element styling (blockquotes, code-block borders, link underlines) and
layout belong in the consuming project: the website's SCSS, or a deck's
own theme.

## Install

In the root of a Quarto project (Quarto 1.8 or later):

```bash
quarto add slangenbach/slangenbach-brand
```

This installs the extension into `_extensions/slangenbach/`. Check that
directory into version control. Every document in the project, including
HTML pages and reveal.js presentations, then uses the brand. The
extension's brand takes precedence over a `_brand.yml` in the project.

To pin a release, add its tag:

```bash
quarto add slangenbach/slangenbach-brand@v1.0.0
```

## Update

```bash
quarto update slangenbach/slangenbach-brand
```

## Colours

Six colours, each with a light and a dark value. Brand palette entries are
the same in both modes, so the pairs are mapped onto theme slots. In your
own SCSS, use the slot variables; `$brand-*` would give you the light value
in dark mode too.

| Colour     | Light     | Dark      | Use in SCSS                  |
|------------|-----------|-----------|------------------------------|
| paper      | `#faf8f3` | `#17181b` | `$body-bg`                   |
| ink        | `#1f2328` | `#e7e3da` | `$body-color`                |
| ink-muted  | `#6b665f` | `#9b968c` | `$secondary`                 |
| rule       | `#e4dfd5` | `#2c2d31` | `$tertiary`                  |
| accent     | `#a3421c` | `#e8895c` | `$primary` (links follow it) |
| code-paper | `#f1ede4` | `#202125` | `$code-bg`, `$code-block-bg` |

reveal.js presentations use the light values.

## Fonts

Source Serif Pro (text and headings, weights 400, 600 and 700 with italics)
and JetBrains Mono (code) load from [Bunny Fonts][bunny]. This means:

- Each visitor's browser requests the fonts from `fonts.bunny.net`, which
  sends their IP address to that third party. Mention this in the privacy
  policy of any website that uses the brand.
- Without an internet connection, the browser uses fonts it has cached from
  an earlier visit, or otherwise falls back to system fonts. To be safe,
  open a presentation once while online before presenting offline, in the
  same browser.

Why not self-hosted, and why not Source Serif 4:

- Quarto 1.10 doesn't copy brand font files into reveal.js output, so
  bundled fonts would only work on HTML pages.
- Quarto writes font family names into CSS unquoted. "Source Serif 4" ends
  in a digit, which makes the CSS invalid and the browser falls back to
  Times. Source Serif Pro is its predecessor, with the same design and a
  name without a digit.

## Preview and test

[`example.qmd`](example.qmd) is a small document that uses the brand. Render
it as an HTML page (`example.html`) and a reveal.js presentation
(`example-slides.html`):

```bash
quarto render example.qmd
```

To preview with live reload while changing the brand:

```bash
quarto preview example.qmd
```

[`tests/acceptance.sh`](tests/acceptance.sh) renders the example and checks
that both outputs carry the brand's fonts and colours:

```bash
tests/acceptance.sh
```

## Release

After merging a change, tag a release so projects can pin it:

```bash
git tag v1.0.0 && git push origin v1.0.0
```

Keep the tag in step with `version` in
[`_extensions/slangenbach/_extension.yml`](_extensions/slangenbach/_extension.yml).

[quarto]: https://quarto.org
[site]: https://stefan.langenbach.online
[brand-yml]: https://posit-dev.github.io/brand-yml/
[bunny]: https://fonts.bunny.net
