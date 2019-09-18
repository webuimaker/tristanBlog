---
layout: post
title:  Austin Sprawl
date:   2019-09-14 21:48:20 +0300
description: Mapping Austin's urban sprawl using permit data
img: posts/2019-09-14-austin-sprawl/cover.png
tags: [Geospatial, Austin]
---

This post is similar to my [previous post][austin-crime]: a quick visualization of a large geospatial dataset provided by the City of Austin.
This time I'm looking at Austin's permit data over the last 38 years.
You can download the dataset [here][permit-dataset], it has nearly 2 million rows, 68 columns.
You can find the script I used to generate the visualizations in this post [here][script]
We're only really interested in the latitude, longitude, and year, so we read in the data from the CSV file we download:

{% highlight python %}
import pandas as pd

df = pd.read_csv('Issued_Construction_Permits.csv')

ndf = df[[
    'Calendar Year Issued',
    'Latitude',
    'Longitude',
    'Work Class' ]]

{% endhighlight %}

Now we loop through all years and plot all new permits (permits issued for new buildings) before the given year (colored by year):

{% highlight python %}

import matplotlib.pyplot as plt

for superyear in range( 1981, 2018):

  # initialize figure with correct aspect ratio
  fig, ax = plt.subplots(figsize = (8, 8 * ratio))

  # set background color to black
  ax.set_facecolor('k')

  # loop over all years before superyear
  for year in range(superyear, 1980, -1):

    # convert year to index between 0 and 1, for colormap
    color_idx = (year - 1981) / float(2018 - 1981)

    # get latitude and longitude of all new permits in the given year
    lats = ndf[
      ((ndf['Calendar Year Issued'] == year) &
      (ndf['Work Class'] == 'New'))]['Latitude']
    lons = ndf[(
      (ndf['Calendar Year Issued'] == year) &
      (ndf['Work Class'] == 'New'))]['Longitude']

    # plot latitude and longitude
    ax.scatter(
      lons,
      lats,
      s = 0.15,
      linewidth = 0,
      facecolor = cmap(color_idx),
      marker = ',')

    # draw year in upper right corner
    ax.text(
      x_ub-0.01,
      y_ub-0.01,
      str(superyear),
      fontsize = 20,
      color = 'w',
      ha = 'right',
      va = 'top')

    # set latitude and longitude limits
    ax.set_xlim(x_range)
    ax.set_ylim(y_range)

    plt.subplots_adjust(0,0,1,1)

  # save figure
  plt.savefig(f'new_permits_all_years/{superyear}.png', dpi = 200)
  plt.close()

{% endhighlight %}

Converting all images into a single gif using the ImageMagick bash command:

{% highlight bash %}
convert *.png -delay 0 -loop 0 sprawl.gif
{% endhighlight %}

results in the following:

{:.eqcol}
| [![Visualization](/assets/img/posts/2019-09-14-austin-sprawl/sprawl.gif)](/assets/img/posts/2019-09-14-austin-sprawl/sprawl.gif)  | [![Legend](/assets/img/posts/2019-09-14-austin-sprawl/colorbar.png)](/assets/img/posts/2019-09-14-austin-sprawl/colorbar.png) |
|:---:|:---:|
| New permits by year | Colorbar |

We see that Austin's borders have expanded significantly in the last nearly 40 years, commonly referred to as urban sprawl.
The plots using all permits tells a similar story as the plots using only new permits: below shows plots for all permits in 1981 compared to 2018:

{:.eqcol}
| [![Visualization](/assets/img/posts/2019-09-14-austin-sprawl/1981.png)](/assets/img/posts/2019-09-14-austin-sprawl/1981.png)  | [![Legend](/assets/img/posts/2019-09-14-austin-sprawl/2018.png)](/assets/img/posts/2019-09-14-austin-sprawl/2018.png) |
|:---:|:---:|
| All permits in 1981 | All permits in 2018 |

The data is all consistent with [this New York Times story][nyt], which shows that Austin is among the worst cities in terms of urban sprawl; between 2010 and 2017 Austin decreased in average neighborhood density by 5% despite growing by nearly 20% over the same time period.

[austin-crime]: {{ site.baseurl }}{% link _posts/2019-09-14-austin-crime.markdown %}
[script]: https://github.com/trislee/misc_scripts/blob/master/austin_permits.py
[permit-dataset]: https://data.austintexas.gov/Building-and-Development/Issued-Construction-Permits/3syk-w9eu
[nyt]: https://www.nytimes.com/2017/05/22/upshot/seattle-climbs-but-austin-sprawls-the-myth-of-the-return-to-cities.html