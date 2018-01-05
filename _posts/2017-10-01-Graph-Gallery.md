---
title: Graph Gallery
layout: post
date: 2017-10-01 11:20
author: WeifanD
published: true
tag:
- R
- Visual
- ggplot2
---
 
National holiday is coming! Let us have some fun.
 
Belows are the bunch of amazing graphs.

 
### The hourly heatmap
 
![plot of chunk unnamed-chunk-2](/figures/unnamed-chunk-2-1.png)
 
 
### Social network
![plot of chunk unnamed-chunk-3](/figures/unnamed-chunk-3-1.png)
 
### Portfolio Map

{% highlight r %}
#Portfolio Map
#install.packages("leafletR")
library(leafletR)
 
# load example data (Fiji Earthquakes)
data(quakes)
 
# store data in GeoJSON file (just a subset here)
q.dat <- toGeoJSON(data=quakes[1:99,], dest=tempdir(), name="quakes")
 
# make style based on quake magnitude
q.style <- styleGrad(prop="mag", breaks=seq(4, 6.5, by=0.5), 
                     style.val=rev(heat.colors(5)), leg="Richter Magnitude", 
                     fill.alpha=0.7, rad=8)
 
# create map
q.map <- leaflet(data=q.dat, dest=tempdir(), title="Fiji Earthquakes", 
                 base.map="water", style=q.style, popup="mag")
 
# view map in browser (png does not work)
#png("#19_portfolio_map_leafletR_earthquake.png" , width = 800, height = 600)
#png("#19_map_leafletR_earthquake.png" , width = 480, height = 480)
q.map
{% endhighlight %}
 
## Animate the plot
 
The gganimate library allows to make animated plots using the ggplot2 syntax. This example comes from the github repository of the library, visit it for more explanations!
 
 

{% highlight r %}
# Make a ggplot, but add frame=year: one image per year
p <- ggplot(gapminder, aes(gdpPercap, lifeExp, size = pop, color = continent, frame = year)) +
 geom_point() +
 scale_x_log10() +
 theme_bw()
 
# Make the animation!<U+00E7>
gganimate(p)
{% endhighlight %}

![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-1.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-2.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-3.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-4.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-5.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-6.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-7.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-8.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-9.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-10.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-11.png)![plot of chunk unnamed-chunk-5](/figures/unnamed-chunk-5-12.png)

{% highlight r %}
# Save it to Gif
gganimate(p, "#271_gganimate.gif")
{% endhighlight %}



{% highlight text %}
Error in file(file, "rb"): cannot open the connection
{% endhighlight %}
 
