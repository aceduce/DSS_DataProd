## Major Splots League and Politics
This Explorer is trying to duplicate the idea from below link.

Data Source: https://github.com/fivethirtyeight/data/tree/master/nfl-fandom

### Future work
1.Include the search times for other sports league, such as NASCAR. Esseitally, expand to

```{r}
 selectInput("sports",h4("League to choose"), 
            choices = list("NBA"="nba","MLB"="mlb","NHL"="nhl",
                                 "NASCAR"="nascar","CBB"="cbb",
                                 "CFB"="cfb", "All"="all")
```

2.Extract the search numbers from Google directly.

3.Improve the `nvd3` from `rCharts` plots. (Use`Java`). Inset the linear fit line in the "Analytics" tab.

4.Improve the details for a few fonts. 




**Note**: Since I didn't use the API to collect data, the current data might not be 100% accurate.  
Date updated: 10/30/2017
About author: Jie Yang
