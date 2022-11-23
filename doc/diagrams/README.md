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
* Additional clarifying information may be found in the [GitBook documentation] for diagrams that are referenced there.
* Recommended disclaimer for documentation page on which diagrams are referenced:
    * (If accessing the below diagram via [GitBook], you may need to switch web browsers to view an enlarged version, which can be activated by clicking on the image.)

## Representative diagrams

* [modules.md] has a color theme matched to [GitHub]'s color schema.
* [matching-engine.md] has complexly-nested subgraphs and different classes.

<!---Alphabetized reference links-->
[`images`]:              images
[`mermaid.js`]:          https://mermaid-js.github.io
[`src`]:                 src
[GitBook]:               https://gitbook.com
[GitBook Documentation]: ../doc-site/
[GitHub]:                https://github.com
[mermaid.live]:          https://mermaid.live
[modules.md]:            src/modules.md
[matching-engine.md]:    src/scraps/matching-engine.md