---
layout: post
title:  Fascist Forge Scraping
date:   2019-09-02 03:32:00 +0300
description: Scraping data from a Nazi forum
img: posts/2019-09-02-fascist-forge/0052_cover.jpg
tags: [Anti-fascism, Fascist Forge]
image_sliders:
  - example_slider
---
*Disclaimer: I hope it's clear by the content of this post that I am fundamentally opposed to Fascism in all its forms. I'm publishing this information because I think more people need to be aware of the state, tactics, and objectives of the militant neo-Nazi movement in the United States.
I hope this information can be useful to ordinary citizens, anti-fascist activists, and researchers alike.*

I recently became aware of the website [Fascist Forge][ff], a militant neo-Nazi forum.
Their *About Us* states:
>Fascist Forge was created in the spring of 2018 to provide real world Fascists with an online platform to make connections, share resources, organize, and ultimately further the Fascist Worldview. The purity of our worldview is our highest ideal and we have zero tolerance for anything that opposes it. The site has purposely been modeled after Ironmarch.org, which prior to its shutdown was the foremost Fascist website in the world. Our aim is to continue where they left off.

There is some good information about the modern militant neo-Nazi movement from [these][splc] [three][icct] [articles][hanrahan], but I couldn't find a lot of information, particularly quantitative information, on Fascist Forge (abbreviated as FF from here on out), so I figured I'd collect some data on my own.

FF has a lot of its material (user pages and certain threads) available only to members, so I created an account.
When poking around their website, I found that their user pages and forum threads were indexed in a convenient way: the page for the 1012-th user is
{% highlight shell_session %}
https://fascistforge.com/index.php?app=core&module=members&controller=profile&id=1012
{% endhighlight %}
and  the page for the 1012-th forum thread is
{% highlight shell_session %}
https://fascistforge.com/index.php?app=forums&module=forums&controller=topic&id=1012
{% endhighlight %}

Using [Selenium][selenium] and [BeautifulSoup][beautifulsoup], I wrote Python scripts to loop over all users, download their information, and store it in a Pandas DataFrame. These fields were:
* username
* forum reputation
* number of forum posts
* number of times they had the most "liked" post of the day
* number of followers
* date and time they joined FF
* date and time of last visit to FF
* stated age
* stated location
* stated religion
* stated ideology
* forum rank
* url of cover image
* url of profile image

I used similar scripts to get information for each forum thread, with the following fields:
* thread headline
* date and time of thread creation
* thread author
* number of pages
* thread category

And for each comment in each thread I collected the following fields:
* date and time of comment creation
* comment author
* comment text

The [scripts][github-scripts], [datasets][github-data], and [instructions][github-readme] for running the scripts can all be found on [my GitHub][github-repo].

While I was playing with the comment data, I came across a link to a FF Riot chat room.
Using the [matrix-dl][matrix-dl] utility, I exported the chat logs and uploaded them to my GitHub in the [data][github-data] subirectory under the title "chat.txt".

Looking at the data, a few observations are worth noting.
The first is that relatively users are few full-fledged "Members".
Prospective members (called "Newcomers") are required to complete a Membership Exam, for the purpose "to separate the genuine and devoted from the unfit and incompatible".
There are broadly three distinct ranks FF users can attain:
* "Newcomer" - user who has not passed the Membership Exam. There are 761 total Newcomers.
* "Mengele Victim" - user who has been banned. There are 171 total Mengele Victims.
* "Member" - user who has passed the membership Exam. There are only 129 total members.

| [![User Rank Distribution](/assets/img/posts/2019-09-02-fascist-forge/single_bar.svg)](/assets/img/posts/2019-09-02-fascist-forge/single_bar.svg) |
|:---:|
| Distribution of FF user ranks |

The second observation is that FF has seen better days.
The figure below shows the normalized weekly activity of FF, for three categories: new users, new threads, and new comments.
I define the normalized activity for a given category for a given week as the number of instances of that category in a given week, divided by the maximum number of instances of that category across all weeks.
Looking below at the plot, we see that FF activity was at its peak around February 2019, then dropped to zero for a brief time, followed by a gradual increase.
This lines up with [some][vice] [articles][medium] I found announcing that FF had been shut down some time in February.

| [![Activity](/assets/img/posts/2019-09-02-fascist-forge/activity.svg)](/assets/img/posts/2019-09-02-fascist-forge/activity.svg) |
|:---:|
| FF activity history |

Now let's take a closer look at the users.
The figure below shows the distribution of user ages.

| [![User Age Distribution](/assets/img/posts/2019-09-02-fascist-forge/age.svg)](/assets/img/posts/2019-09-02-fascist-forge/age.svg) |
|:---:|
| FF user age distribution |

Most users claim to be in their late teens and early 20s.
Many users claim their age to be a Nazi-related reference or joke, some worth mentioning are:
* 88 (22 users): a [Nazi reference][adl-88]
* 1488 (6 users): another [Nazi reference][adl-1488]
* 333 (4 users): an apparent reference to [Liber 333][goodreads], a book by the satanist group [Tempel ov Blood][medium-tob] loosely affiliated with Atomwaffen

Finally, I've made an image slider of every unique user profile and cover image, using [this utility][ideal-image-slider].
Scrolling through it is a good way to get a sense of the vibe and aesthetics of the modern neo-Nazi movement.

{% include slider.html selector="example_slider" %}

Some of the most common visual tropes in the imagery were [Black Suns][black-sun], swastikas, [half skull masks][skull-mask], and [SS Totenkopfs][totenkopf].

This is a preliminary post, keep an eye out for updates and more in-depth analysis.

[ff]: https://fascistforge.com
[splc]: https://www.splcenter.org/hatewatch/2019/02/22/atomwaffen-and-siege-parallax-how-one-neo-nazi%E2%80%99s-life%E2%80%99s-work-fueling-younger-generation
[icct]: https://icct.nl/publication/siege-the-atomwaffen-division-and-rising-far-right-terrorism-in-the-united-states/
[hanrahan]: https://medium.com/@Hanrahan/atomwaffendown-c662cb4d1aa6
[selenium]: https://selenium-python.readthedocs.io/
[beautifulsoup]: https://www.crummy.com/software/BeautifulSoup/bs4/doc/
[github-scripts]: https://github.com/trislee/fascist_forge/tree/master/scripts
[github-data]: https://github.com/trislee/fascist_forge/tree/master/data
[github-readme]: https://github.com/trislee/fascist_forge/blob/master/README.md
[github-repo]: https://github.com/trislee/fascist_forge
[matrix-dl]: https://gitlab.gnome.org/thiblahute/matrix-dl
[vice]: https://www.vice.com/en_ca/article/43zn8j/fascist-forge-the-online-neo-nazi-recruitment-forum-is-down
[medium]: https://medium.com/americanodyssey/fascist-forge-neo-nazi-forum-returns-online-f7cb1f672f94
[adl-88]: https://www.adl.org/education/references/hate-symbols/88
[adl-1488]: https://www.adl.org/education/references/hate-symbols/1488
[medium-tob]: https://medium.com/@eggfordinner/nazi-satanist-cults-want-your-blood-2a89c1578a65
[goodreads]: https://www.goodreads.com/en/book/show/18399841-liber-333
[ideal-image-slider]: https://github.com/jekylltools/jekyll-ideal-image-slider-include
[black-sun]: https://en.wikipedia.org/wiki/Black_Sun_(symbol)
[skull-mask]: https://www.splcenter.org/hatewatch/2017/06/20/donning-mask-presenting-face-21st-century-fascism
[totenkopf]: https://en.wikipedia.org/wiki/Totenkopf#Nazi_Germany