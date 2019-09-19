---
layout: post
title:  Fascist Forge Reactions
date:   2019-09-07 11:50:00 +0300
description: Analyzing reaction data from a Nazi forum
img: posts/2019-09-07-fascist-forge-reactions/fascist-forge-reactions_cover.png
tags: [Anti-fascism, Fascist Forge]
---

*This is the second post in a series focusing on the collection and analysis of data from a militant neo-Nazi website, [FascistForge.com][ff]. You can see the first installment [here][fascist-forge-scraping]*

Just like how Facebook allows its users to "react" to posts and comments using emojis, Fascist Forge (FF) allows its users to do the same, except that all of the FF emojis are Nazi-related.

<div>
  <img style="vertical-align:middle" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/like.png" alt='like' width='100'>
  <span style="">Like</span>
</div>

<div>
  <img style="vertical-align:middle" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/gas.png" alt='gas' width='100'>
  <span style="">Gas</span>
</div>

<div>
  <img style="vertical-align:middle" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/hitler_approves.png" alt='hitler_approves' width='100'>
  <span style="">Hitler Approves</span>
</div>

<div>
  <img style="vertical-align:middle" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/mason_1.png" alt='mason_1' width='100'>
  <span style="">Mason +1 (James Mason, author of SIEGE)</span>
</div>

<div>
  <img style="vertical-align:middle" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/rockwell_salute.png" alt='rockwell_salute' width='100'>
  <span style="">Rockwell Salute (George Lincoln Rockwell, founder of American Nazi Party)</span>
</div>

<div>
  <img style="vertical-align:middle" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/shlomo.png" alt='shlomo' width='100'>
  <span style="">Shlomo</span>
</div>

<div>
  <img style="vertical-align:middle" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/sneaky_nazi.png" alt='sneaky_nazi' width='100'>
  <span style="">Sneaky Nazi</span>
</div>

<div>
  <img style="vertical-align:middle" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/anti-fascist.png" alt='anti-fascist' width='100'>
  <span style="">Anti-Fascist</span>
</div>

Just as in the previous post, I wrote a small script based on Selenium and BeautifulSoup and extracted data for all reactions on the website.
You can find the script in the [scripts][github-scripts] page of the [GitHub Repo][github-repo].

Below is a bar chart showing the frequency at which the different reactions occur:
<p align="center">
  <img width="70%" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/reaction_bar.svg">
</p>
"Likes" comprise about 82% of the total reactions.
Let's look a bit closer into how likes are distributed amongst the userbase.
The image below shows the rank-size distribution for the likes received and likes given for all users with more than zero likes given **or** more than zero likes received.
This is consistent with what we saw in the previous post: most of the 1150 or so users are lurkers and haven't liked a single post or had a single post of theirs liked,
<p align="center">
  <img width="70%" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/like_rank.svg">
</p>
We'll focus for now on the users with more than zero likes given **and** more than zero likes received. The scatter plot below shows the number of likes given vs. number of likes received, plotted on a log-log scale because of the large variations in magnitude for these quantities:
<p align="center">
  <img width="70%" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/likes_given_vs_received.svg">
</p>

The distribution is fairly proportional, I was expecting it to be more unequal.
Looking at the ratio of likes received to likes given, we see a similar result: the distribution of the like ratio is symmetric on a logarithmic scale, centered about 1.

<p align="center">
  <img width="70%" src="/assets/img/posts/2019-09-07-fascist-forge-reactions/likes_ratio.svg">
</p>
On one end of the distributions, there are a few users who like other comments 11 times more often than their comments get liked, and on the other end, there are a similar number of users who get their comments liked about 11 times more often than they like other comments.

Time for some fun, let's map out the network structure of liked in FF.
I won't go in-depth regarding how I generated the graphs below, you can read the details in the "like_network_graph.py" script in the [plots][github-plots] directory on my GitHub.
I used the Python packages [HoloViews][holoviews] and [Bokeh][bokeh] to generate the interactive visualization.
I've found HoloViews difficult to use because of the lack of comprehensive documentation, but it can generate some very cool visualizations if you take the time to get it right.
The steps for generating the visualization were:
1. Remove entries from the reactions DataFrame if the user did not have at least one like given **and** at least one like received. This was to make sure the graph visualization looked good and didn't have any dangling nodes.
2. Use [networkx][networkx] to calculate node positions of the graph based on the edge weights.
3. Format data into a structure HoloViews can understand
4. Initialize Graph using HoloViews, save html file using Bokeh backend.

Here's the code I used for step 3, in which ``edf`` and ``ndf`` are DataFrames containing edge and node data respectively, and ``'log degree'`` is a column in the node DataFrame containing the base-10 log of the sum of likes given and likes received:

{% highlight python %}
import holoviews as hv
hv.extension('bokeh')
renderer = hv.renderer('bokeh')

# construct Holoviews graph with Bokeh backend
hv_nodes = hv.Nodes(ndf).sort()
hv_graph = hv.Graph((edf, hv_nodes))
hv_graph.opts(
  node_color = 'log degree',
  node_size=10,
  edge_line_width=1,
  node_line_color='gray',
  edge_hover_line_color = '#DF0000')

# save html of interactive visualizations
renderer.save(hv_graph, 'graph')
{% endhighlight %}

I've colored the nodes by the log of their degree (number of likes given + number of likes received) using the default viridis colormap.
The resulting visualization is shown below:

<div class="include-out">
{% include interactive/ff_like_graph.html  %}
</div>
So that's pretty cool, but there are a lot of edges, which makes it difficult to see the graph's structure, especially in the middle region where the nodes are close together.
Luckily, HoloViews has an edge bundling feature.
For more information about edge bundling, see [these][data-to-viz] [resources][vega].
The extra code needed to bundle the graph edges is shown below:

{% highlight python %}

from holoviews.operation.datashader import bundle_graph

# bundle edges for aesthetics
bundled = bundle_graph(hv_graph)

{% endhighlight %}
The resulting visualization is shown below. I think it looks a lot better, both aesthetically and informationally:

<div class="include-out">
{% include interactive/ff_like_graph_bundled.html  %}
</div>

The graph shows that there is a relatively small group of users who are responsible for a large percentage of all reactions.
The table below shows the top 10 users:

<html>
<head>
<style>
#customers {
  font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

#customers td, #customers th {
  border: 1px solid #ddd;
  padding: 8px;
}

#customers tr:nth-child(even){background-color: #f2f2f2;}

#customers tr:hover {background-color: #ddd;}

#customers th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #DE0000;
  color: white;
}
</style>
</head>
<body>

<table id="customers">
  <tr>
    <th>Username</th>
    <th>Likes Received</th>
    <th>Likes Given</th>
  </tr>
  <tr>
    <td>Nox Aeternus</td>
    <td>331</td>
    <td>312</td>
  </tr>
  <tr>
    <td>Mathias</td>
    <td>216</td>
    <td>256</td>
  </tr>
  <tr>
    <td>Scythian</td>
    <td>192</td>
    <td>262</td>
  </tr>
  <tr>
    <td>Yorkie</td>
    <td>138</td>
    <td>194</td>
  </tr>
  <tr>
    <td>Pugna</td>
    <td>130</td>
    <td>146</td>
  </tr>
  <tr>
    <td>Reaper</td>
    <td>116</td>
    <td>156</td>
  </tr>
  <tr>
    <td>D. Aquillius</td>
    <td>94</td>
    <td>110</td>
  </tr>
  <tr>
    <td>Dakov</td>
    <td>144</td>
    <td>49</td>
  </tr>
  <tr>
    <td>Pestilence</td>
    <td>117</td>
    <td>76</td>
  </tr>
  <tr>
    <td>Gigaboltro</td>
    <td>101</td>
    <td>90</td>
  </tr>
</table>

</body>
</html>


[ff]: https://fascistforge.com
[fascist-forge-scraping]: {{ site.baseurl }}{% link _posts/2019-09-02-fascist-forge.markdown %}
[james-mason]: https://en.wikipedia.org/wiki/James_Mason_(neo-Nazi)
[github-scripts]: https://github.com/trislee/fascist_forge/tree/master/scripts
[github-plots]: https://github.com/trislee/fascist_forge/tree/master/plots
[github-data]: https://github.com/trislee/fascist_forge/tree/master/data
[github-repo]: https://github.com/trislee/fascist_forge
[holoviews]: http://holoviews.org/
[bokeh]: https://bokeh.pydata.org/en/latest/index.html
[networkx]: https://networkx.github.io/
[data-to-viz]: https://www.data-to-viz.com/graph/edge_bundling.html
[vega]: https://vega.github.io/vega/examples/edge-bundling/