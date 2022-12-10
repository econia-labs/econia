# Diagrams

- [Diagrams](#diagrams)
  - [General](#general)
  - [Representative diagrams](#representative-diagrams)

This directory contains assorted diagrams, most of which are generated via [`mermaid.js`], with source files in [`src`] and images in [`images`].

## General

* [`mermaid.js`] diagrams are generated declaratively, and may present occasional rendering artifacts.
* Most [`mermaid.js`] tutorials online present an `%%{init:}` directive on a single line, despite excessive line length.
* The [modules.md] diagram theme is matched to GitHub's color schema.
* `SVG` diagrams can be generated via [mermaid.live]

## Representative diagrams

* [modules.md] has a color theme matched to [GitHub]'s color schema.
* [matching-engine.md] has complexly-nested subgraphs and different classes.

<!---Alphabetized reference links-->

[`images`]:              images
[`mermaid.js`]:          https://mermaid-js.github.io
[`src`]:                 src
[GitHub]:                https://github.com
[mermaid.live]:          https://mermaid.live
[modules.md]:            src/modules.md
[matching-engine.md]:    src/scraps/matching-engine.md