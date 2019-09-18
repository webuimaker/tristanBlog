---
layout: post
title:  Seattle School Demographics
date:   2019-08-17 13:32:20 +0300
description: Demographic analysis of the Seattle Schools student assignment plan
img: posts/2019-08-17-seattle-schools/diversity.jpg
tags: [Geospatial, Seattle]
---
In my freshman year of high school, my school district released a [new student assignment plan][assignment-plan], based on geography rather than choice, as had been the previous policy. I remember thinking that it would be interesting to study how the demographics of Seattle mapped onto the demographics of individual schools, but at the time I didn't know enough about GIS and data science to do anything about it. Well now I do, so here's an attempt.

The first task is collecting the demographic data of Seattle at the finest level of detail possible. That means collecting block-level data from the US Census Bureau. To know which Census blocks are within the Seattle city limits, we can download the shapefiles for the [Seattle 2010 Census Blocks][census-blocks-download]. The [GeoPandas][geopandas-home] library is an incredibly handy and powerful package for dealing with geospatial data, and I'll be using it extensively throughout this article.

Another library I'll be using is [census][census-package], which is a convenient wrapper for the US Census API. To use the US Census API, you need to request a [Census API Key][census-key].

Census data is structured hierarchically: states contain counties, which contain tracts, which contain block groups, which contain blocks. The Census API has limits that restrict the level of geographic detail you can fetch from a single query. For instance, you can't query all blocks in a county, but you can query all tracts in a county and then query all blocks in a given tract. Because of these rules, we first need to determine all tracts in Seattle, then query block-level data for each of those tracts.

Most shapefiles have a ``GEOID10`` field that uniquely specifies a geographic entity. The GEOID10 associated with the shapefile from the City of Seattle consists of a two digit state code, a three digit county code, a six digit tract code, and a 4 digit block code. For example, the GEOID10 "530330067001001" refers to state 53 (Washington), county 033 (King County), tract 67 (Magnolia/Queen Anne), block 1001 (SOME LOCATION). In the following code block, we extract and sort all unique tract numbers:
{% highlight python %}
import geopandas as gpd

blocks_gdf = gpd.read_file( 'path/to/2010/census/shapefile.shp' )
blocks_gdf = blocks_gdf[['GEOID10', 'geometry']]

tracts = set([k[5:11] for k in blocks_gdf['GEOID10']])
tracts = sorted(list(tracts))
{% endhighlight %}

Now we prepare the census queries. I create dicts of census variables and their corresponding descriptions, which I got from a very long list of the [2010 Census variables][census-variables]. The Census records Hispanic heritage [differently][hispanic-origin] than other ethic backgrounds, so for simplicity I'm not including that variable.
{% highlight python %}
CODE_DICT = {
  'P001001' : 'all',
  'P003002' : 'white',
  'P003005' : 'asian',
  'P003003' : 'black',
  'P003004' : 'native',
  'P003006' : 'pacific' }
{% endhighlight %}

Now we loop over all tracts, querying all census variables for all blocks:
{% highlight python %}
from census import Census

c = Census( "YOUR_CENSUS_KEY", year = 2010 )

tract_responses = dict()

for i, tract in enumerate(tracts):

  # get census data from te SF1 file, from 2010
  tract_responses[tract] = c.sf1.get(
    tuple(CODE_DICT.keys())),
    {
      'for' : 'block:*',
      'in': f'state:53+county:033+tract:{tract}'
    }
  )
{% endhighlight %}
The next step is some ugly code to coalesce the census data contained in ``tract_responses`` into a single pretty GeoDataFrame. You can read it on [my GitHub][github-seattle], but I'm omitting it here for the sake of brevity. For fun, I've included some plots of population density by block for different ethnic backgrounds. These choropleths were very easy to generate using the GeoDataFrame ``plot()`` method. Blocks with zero population were set to the background color.

| [![White](/assets/img/posts/2019-08-17-seattle-schools/white.svg)](/assets/img/posts/2019-08-17-seattle-schools/white.svg)  | [![Black](/assets/img/posts/2019-08-17-seattle-schools/black.svg)](/assets/img/posts/2019-08-17-seattle-schools/black.svg) | [![Asian](/assets/img/posts/2019-08-17-seattle-schools/asian.svg)](/assets/img/posts/2019-08-17-seattle-schools/asian.svg) |
|:---:|:---:|:---:|
| White | Black | Asian |

Now that we have block-level demographic data organized nicely in a GeoDataFrame, the next step is to determine which blocks are included in a given school's attendance area boundary. We first download and extract the [attendance area boundaries][boundary-shapefiles]. An important attribute of a shapefile is its [coordinate reference system][crs] (CRS), which specifies how coordinates on a spherical surface are projected onto a flat surface. These CRS are often represented as *proj4* strings, such as the following, which is a nice Seattle-centered projection:
{% highlight python %}
SEATTLE_PROJ = "+proj=lcc +lat_1=47.5 +lat_2=48.73333333333333 +lat_0=47 +lon_0=-120.8333333333333 +x_0=500000.0000000002 +y_0=0 +datum=NAD83 +units=us-ft +no_defs "
{% endhighlight %}

We merge our block-level GeoDataFrame with out block-level demographic DataFrame, and convert it to the ``SEATTLE_PROJ`` CRS:

{% highlight python %}
block_gdf = block_gdf.merge(demog_data_df)
block_gdf = block_gdf.to_crs(crs = SEATTLE_PROJ)
{% endhighlight %}

We also read-in the shapefile for the High School attendance area boundaries, convert to the ``SEATTLE_PROJ`` CRS, and remove extraneous columns:
{% highlight python %}
hs_gdf = gpd.read_file("path/to/highschool/boundary/shapefile.shp")
hs_gdf = hs_gdf.to_crs(crs = SEATTLE_PROJ)
hs_gdf = hs_gdf[['HS_ZONE', 'geometry']]
{% endhighlight %}

Now we loop over all school attendance area boundary geometries and all block geometries to see if the attendance area completely contains the block. To do this we employ the ``.contains()`` method for GeoPandas geometries. We store the data in a 2D boolean array of shape (number of schools, number of blocks), so that the $$i,j$$-th element is true if school boundary $$i$$ contains block $$j$$, and False otherwise:
{% highlight python %}
contains_shape = (hs_gdf.shape[0], block_gdf.shape[0])
contains_arr = np.zeros(contains_shape, dtype = np.bool_)
for i in range(contains_shape[0]):
  for j in range(contains_shape[1]):
    contains_arr[i, j] = hs_gdf.loc[i]['geometry'].contains(block_gdf.loc[j]['geometry'])
{% endhighlight %}

We can plot the blocks, colored by containing school, along with the assignment area shapefiles, to make sure we performed the previous steps correctly:

| [![Elementary School Map](/assets/img/posts/2019-08-17-seattle-schools/blocks_by_geozone_ES.svg)](/assets/img/posts/2019-08-17-seattle-schools/blocks_by_geozone_ES.svg)  | [![Middle School Map](/assets/img/posts/2019-08-17-seattle-schools/blocks_by_geozone_MS.svg)](/assets/img/posts/2019-08-17-seattle-schools/blocks_by_geozone_MS.svg) | [![High School Map](/assets/img/posts/2019-08-17-seattle-schools/blocks_by_geozone_HS.svg)](/assets/img/posts/2019-08-17-seattle-schools/blocks_by_geozone_HS.svg) |
|:---:|:---:|:---:|
| Elementary School | Middle School | High School |

The last step is to calculate the average population for the contained blocks for each school, for each race.
{% highlight python %}
school_list = list(hs_gdf[f'{school_level_code}_ZONE'])
race_list = list(block_gdf)[3:]

race_by_school = np.zeros((len(school_list), len(race_list)))
for i, s in enumerate(school_list):
  race_by_school[i] = np.mean(block_gdf.loc[contains_arr[i]])[2:]

rbs_df = pd.DataFrame(race_by_school)
rbs_df.columns = race_list
rbs_df.insert(0, 'school', school_list)

rbs_sort = race_by_school[np.flipud(np.array(np.argsort(rbs_df['white'])))]
{% endhighlight %}

Finally we can plot the demographic data by school, as shown below:

| [![Elementary School Demographics](/assets/img/posts/2019-08-17-seattle-schools/demographics_by_school_geozone_ES.svg)](/assets/img/posts/2019-08-17-seattle-schools/demographics_by_school_geozone_ES.svg)  | [![Middle School Demographics](/assets/img/posts/2019-08-17-seattle-schools/demographics_by_school_geozone_MS.svg)](/assets/img/posts/2019-08-17-seattle-schools/demographics_by_school_geozone_MS.svg)  | [![High School Demographics](/assets/img/posts/2019-08-17-seattle-schools/demographics_by_school_geozone_HS.svg)](/assets/img/posts/2019-08-17-seattle-schools/demographics_by_school_geozone_HS.svg) | [![High School Demographics](/assets/img/posts/2019-08-17-seattle-schools/demographics_by_school_legend.svg)](/assets/img/posts/2019-08-17-seattle-schools/demographics_by_school_legend.svg)
|:---:|:---:|:---:|:---:|
| Elementary School | Middle School | High School |  |

[assignment-plan]: https://www.seattleschools.org/UserFiles/Servers/Server_543/File/District/Departments/Enrollment%20Planning/Student%20Assignment%20Plan/New%20Student%20Assignment%20Plan.pdf
[census-blocks-download]: http://data-seattlecitygis.opendata.arcgis.com/datasets/38105e262d9441b59b2dde020cb02b40_13.zip
[geopandas-home]: http://geopandas.org/
[census-package]: https://github.com/datamade/census
[census-key]: https://api.census.gov/data/key_signup.html
[census-variables]: https://api.census.gov/data/2010/dec/sf1/variables.html
[hispanic-origin]: https://www.census.gov/prod/cen2010/briefs/c2010br-02.pdf
[boundary-shapefiles]: https://www.seattleschools.org/UserFiles/Servers/Server_543/File/District/Departments/Enrollment%20Planning/Maps/gisdata/SPS_AttendanceAreasAndSchools_Shapefiles_2019_2020.zip
[crs]: http://geopandas.org/projections.html
[github-seattle]: https://github.com/trislee/seattle_schools_demographics/blob/master/block_data_plots_geopandas.py