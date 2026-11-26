# lewis_software

lewis_software is the source of lewis.software, my home on the web and the publisher behind my Dart tools. It is a static site built with Jaspr and served from Cloudflare, and it gathers nothing about the people who read it: no analytics, no cookies, and no request to any host but its own.

<!-- office doc index -->

## Docs

- [Property index](docs/property-index.md) - Every property the code holds, each by its number beside its property test, and its Lean declaration where it is proved.

<!-- /office doc index -->

## AI usage

Nothing here is "vibe-coded". Claude writes the code, far faster than I could by hand, but the design and the standard it's held to are mine. It runs inside tooling I've built on top of Claude Code, so every change is planned before it's written, then passes independent review, the full test suite and a strict quality gate before it reaches me. I review every line and send it back until it meets that standard, which is why every commit is mine. `CLAUDE.md` is gitignored because it holds details of my own setup, not to hide AI's part.

## Contributing

This repo is a public mirror of a private one, so nothing is ever merged here. Bug reports and feature requests are welcome as GitHub issues. A pull request is read as a proposal, and anything taken up is rebuilt and credited.
