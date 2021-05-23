---
layout: post
title: "How to cleanse your AWS bill"
categories: how-to
tags: [how-to, aws]
---

Ever wondered what a [black hole](https://en.wikipedia.org/wiki/Black_hole#:~:text=A%20black%20hole%20is%20a,to%20form%20a%20black%20hole.){:target="_blank"} looks like? My AWS Billing—or yours—might be one of the closest things to a black hole on earth. So scary, and so hard to remove things from it, firstly because we don't know what services to remove nor the regions for those unwanted services.

<!--more-->

Let's focus on how to remove things from the AWS bill, which is the main task that will definitively cleanse our bill. It's so easy to spin up new services in AWS and forget about them, some might be cheap some others might not be that cheap; and given that AWS—at the time of this writing—provides over 175 services in several regions each, it becomes quite a task to manage all of your services in all of the regions you used.

Enter the Bills page. Go to your Billing Dashboard, and then on the left sidebar, under the Billing section, click on [Bills](https://console.aws.amazon.com/billing/home#/bills){:target="_blank"}. Below AWS Service Charges you can see all of the services you have signed up for, and inside each of them, you can see the incurred costs per region. This way you just need to figure out what services are not in use, then go to their regions and remove them.

![AWS Bills Page](/assets/aws-bills-page.png)

This way I was able to spot an unused RDS instance and a very old Amplify instance, both burning money with no returns.
