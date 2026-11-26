---
type: knowledge
aliases: properties, invariants, property tests, property numbers
---

# Property index

Every property the code holds, each by its number beside its property test, and its Lean declaration where it is proved. A section holds each part of the code, and a property sits under the part whose code holds it, the ones a reader most needs first. A number is the part's code and the property's place in its section, `PAG-1` and on, so it says at a glance which part holds the property, and none is worn twice.

A property's test wears its number and its words as its title.

## Pages

### PAG-1: A page's requests to the site alone

Every page the build writes requests nothing from any host but the site's own.

Test: [test/requests_test.dart](../test/requests_test.dart)

### PAG-2: A link between pages

Every link between the site's pages leads to a page the build wrote.

Test: [test/links_test.dart](../test/links_test.dart)

### PAG-3: A pub.dev link

Every pub.dev link a page shows is a published tool's package, or the publisher while a tool is published.

Test: [test/links_test.dart](../test/links_test.dart)

### PAG-4: A path with no page

A path no page is written to finds the not-found page.

Test: [test/page_test.dart](../test/page_test.dart)

## Hosting

### HOS-1: A name in a header

No name, however written, puts a line break or a control character in a header.

Test: [test/message.test.mjs](../test/message.test.mjs)

### HOS-2: A field within its limit

Each of a post's name, email and message is read for sending exactly while it is within its limit, the others within theirs.

Test: [test/message.test.mjs](../test/message.test.mjs)
