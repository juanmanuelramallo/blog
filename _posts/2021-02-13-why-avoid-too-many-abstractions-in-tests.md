---
layout: post
title: "Why avoid too many abstractions in tests?"
categories: ruby
tags: [ruby, testing, rspec, shared examples]
excerpt: "Too many abstractions for our test code is like highlighting every single word of the book you're reading. You'd only want to highlight the most important parts right?"
---

### Intro
There's production code, and there's test code. Production code refers to any portion of the codebase that is executed in production environments. Similarly, test code refers to any portion of the codebase that is solely executed in testing environments, where production code is exercised via the test code.

Test code needs to be explicit, easy to read and understand what's going on. Test abstractions, like shared examples, are usually against what we need out of test code.

### Why not to DRY test code?
Refactoring production code tested with several abstractions in test code becomes harder. This is because one single test abstraction is used across several places in test code, potentially causing your changes to break some tests but not all of them. Finally, triggering a refactoring task on the test abstraction as well or maybe even updating your tests that failed to stop using the abstraction cause it no longer fits the test.

Test reports with failures are harder to read. If a test using an abstraction failed inside the abstraction then the report will show where it failed first, and that is inside the abstraction. It requires the developer to read over the stack trace to check what test called the abstraction in order to find out what test is actually failing.

This is the output of RSpec's Shared Examples

<pre>
Finished in 3.17 seconds (files took 2.49 seconds to load)
<font color="#CC0000">47 examples, 5 failures</font>

Failed examples:

<font color="#CC0000">rspec ./spec/requests/api/v1/users_spec.rb[1:2:2:2:1:1:1]</font> <font color="#06989A"># Api::V1::Users PATCH #update behaves like ...</font>
<font color="#CC0000">rspec ./spec/requests/api/v1/users_spec.rb[1:2:4:1:1:1]</font> <font color="#06989A"># Api::V1::Users PATCH #reset_change_email behaves like ...</font>
<font color="#CC0000">rspec ./spec/requests/api/v1/users_spec.rb[1:2:5:1:1:1:1]</font> <font color="#06989A"># Api::V1::Users PATCH #request_remove_user behaves like ...</font>
<font color="#CC0000">rspec ./spec/requests/api/v1/users_spec.rb[1:2:1:1:1:1]</font> <font color="#06989A"># Api::V1::Users GET #show behaves like ...</font>
<font color="#CC0000">rspec ./spec/requests/api/v1/users_spec.rb[1:2:3:1:1:1]</font> <font color="#06989A"># Api::V1::Users PATCH #reset_api_key behaves like ...</font>
</pre>

<sub>beer's on me if you can tell where the failure occurred</sub>

### Don't get me wrong
Too many abstractions for our test code is like highlighting every single word of the book you're reading. You'd only want to highlight the most important parts right?

With test code is quite similar, we don't want to abstract everything but we'd rather keep test code as explicit and readable as possible and at the same time provide abstractions for the parts that are not really meaningful for test cases. For instance, the factory pattern to create objects for test code is perfect – re: [FactoryBot](https://github.com/thoughtbot/factory_bot). [Custom matchers](https://relishapp.com/rspec/rspec-expectations/docs/custom-matchers) are also a valid way to introduce abstractions while keeping our test code explicit and declarative.

To sum up, abstractions for non meaningful parts of test code are valid and really useful. Abstractions for test code that describes actual behavior of the system are never\[<cite>[*]({{ page.url}}#i-can-live-with-it)</cite>\] good.

<sub id='i-can-live-with-it'>* I wrote a shared example last month, out of a code review suggestion, and I can live with it</sub>

