---
layout: post
title: "I don't use nil"
categories: ruby
tags: [ruby]
excerpt: "NoMethodError: undefined method 'excerpt' for nil:NilClass"
---

I don't use `nil`, or at least I try not to.

```
NoMethodError: undefined method 'some_method' for nil:NilClass
```

This is one of the most common errors seen on production systems. And it's likely to happen everywhere where a variable can reference to a null value. Here are some case studies about the topic.

## Migrations

When creating/updating a table I always consider adding a `null: false` constraint and a default value accordingly. For string values, the default would be an empty string. For number values, the default value would be zero.

This allows us to do operations with those columns without worrying about them being `nil`, because we took care of that at the database level. For instance, let's consider a `Post` model in a blogging system:

```ruby
# db/migrate/...
class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      # [snip]

      # not bad
      t.string :excerpt

      # better
      t.string :excerpt, null: false, default: ''
    end
  end
end

# app/views/posts/show.html.erb
<p>
  <%= @post.excerpt.downcase %>
</p>
```

In this particular example, sending `downcase` to `Post#excerpt` will always work because we ensured that the value will always return a String object.

## Enums

Let's consider that any post can have a certain category. Since these categories won't have any extra info nor behavior, we'll use an enum attribute in the post model.

```ruby
# db/migrate/...
class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      # [snip]

      # not bad
      t.integer :category

      # better
      t.integer :category, null: false, default: 0
    end
  end
end
```

We can easily add a default enum option to represent a post without a category. And why is it better? For the simple reason that the `Post#category` method will always return the same object type. This will cause the code to avoid checking for `nil` when working with the category, and will also make the safe navigational operator useless when working with this attribute.

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  enum category: { general: 0, lifestlye: 1, art: 2, misc: 3 }
end
```

In this example we are using the category named `general` as the default one.

## NullObject

This approach is an elegant way to represent a null value. It is somewhat similar to the enum's case study. Here's an excellent [article from thoughtbot](https://thoughtbot.com/blog/rails-refactoring-example-introduce-null-object){:target="_blank"} about this pattern.

## undefined method 'conclusion' for nil:NilClass

To sum up, I don't use `nil` because I don't want the program to potentially raise this `NoMethodError`. To avoid it, it's just as easy as not handling null values in the codebase. 

And this is Tony Hoare, the inventor of `nil`:

> I call it my billion-dollar mistake. It was the invention of the null reference in 1965. At that time, I was designing the first comprehensive type system for references in an object oriented language (ALGOL W). My goal was to ensure that all use of references should be absolutely safe, with checking performed automatically by the compiler. But I couldn't resist the temptation to put in a null reference, simply because it was so easy to implement. This has led to innumerable errors, vulnerabilities, and system crashes, which have probably caused a billion dollars of pain and damage in the last forty years. [src](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare/){:target="_blank"}

