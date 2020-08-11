---
layout: post
title:  "When objects become super objects"
categories: ruby
tags: [ruby, rails, oop]
excerpt: Comments to my past self about a basic principle of OOP.
---

A pencil. We use a pencil to write. And that's it. (Let's forget about some pencils that come with an eraser in one end, in this world they don't exist)

We are in the "digital transformation" era, right? So I came up with the idea of including a simple scanner in the body of the pencil, to be able to digitalize everything written with the pencil. It's really handy!

I always struggled to share my technical drawings when exchanging thoughts in groups, so I think a mini projector on top of the pencil would be a great addition. It's amazing, I can show my drawings directly in the wall, no need for any external projector!

Oh, and a laser pointer on it. You know, everyone loves playing with lasers.

_We call it The Pencil 3000 ™_

![the-pencil-3000](/assets/pencil-3000.png)

Let's stop here. I've experienced this very same line of thinking when creating/updating classes.

## Multiple responsibility classes: Real life examples

These are the places where I've encountered myself working with this approach:

<small>_CTMPS_ means "comment to my past self".</small>

#### 1. Models

Several times I wrote methods in the model that were only being used in the views. _CTMPS_: It'd be better to use a [presenter object](https://www.rubyguides.com/2019/09/rails-patterns-presenter-service/){:target="_blank"} for those.

Numerous times I found myself writing callback methods in the model, with the purpose of sending emails or adding default values in the model. _CTMPS_: Sending emails seems like a side effect of a user action, why don't trigger them in the controller instead? And about setting default values, what about setting them using the [ActiveRecord::Attributes API](https://api.rubyonrails.org/classes/ActiveRecord/Attributes/ClassMethods.html){:target="_blank"}?

Don't get me started with inline validation methods. This I one I abused. I'm sorry. _CTMPS_: There are no taxes for new classes, create a [validator class](https://api.rubyonrails.org/classes/ActiveModel/Validator.html){:target="_blank"} and be done with it. Peace out.

#### 2. Form objects

Select tags with options that are not DB backed. Guilty. I more than once wrote a method in the form object to provide the options to be used in the select tag, in the view. _CTMPS_: It's ok no big deal, but what about using a presenter object for this? Given it's a view-only matter.

----
At this point it feels like I'm seeking absolution from my sins. Hopefully you haven't experienced any of these. But in any case, let me share you one more example.

----

#### 3. Page objects

Testing usually requires [4 steps](https://thoughtbot.com/blog/four-phase-test){:target="_blank"}: setup, exercise, assertions and teardown. And when testing web applications, end users interact with HTML documents. _Enter page objects_. So we use [page objects](https://martinfowler.com/bliki/PageObject.html){:target="_blank"} to wrap the HTML and provide a meaningful API to be used in test code. This includes the exercise and assertion steps of testing. But I gotta be honest, it is so easy and pleasant to just write a new method into the page object to do the setup and create instances, update stuff, set up environment variables and whatever needed for our tests to run. _CTMPS_: It's as easy and pleasant to extract the creational part into a support [module](https://rubyapi.org/2.7/o/module){:target="_blank"} in your specs, and keep your page objects fulfilling their _true purpose_.

----
Remember The Pencil 3000™? I can't imagine how would I sharp the pencil, with all that stuff around it.

----

## Single-responsibility principle

"[...] each software module should have one and only one reason to change." [Better read it from here](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html){:target="_blank"}

