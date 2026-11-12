# AGENTS.md

This repo holds Stefan Langenbach's brand (colours and fonts) as a Quarto brand extension in `_extensions/slangenbach/`. It is used by the website (slangenbach/slangenbach.github.io) and by Stefan's personal slide decks.

- Keep the brand to what applies to every medium: colours and fonts. Element styling and layout belong in the consuming project.
- Run `tests/acceptance.sh` after any change to `brand.yml`.
- Bump `version` in `_extensions/slangenbach/_extension.yml` and tag a matching release after merging (see README).
- Design decisions and vocabulary live in the website repo's `GLOSSARY.md` and `docs/adr/`.
