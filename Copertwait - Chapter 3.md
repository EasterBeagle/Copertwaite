Forecasting - Chapter 3
-----------------------

Businesses rely on forecasts of sales to plan production, justify marketing de-
cisions, and guide research.

 

A very efficient method of forecasting one variable is to find a related
variable that leads it by one or more time intervals. The closer the
relationship and the longer the lead time, the better this strategy becomes. The
trick is to find a suitable lead variable.

 

A variation on the strategy of seeking a leading variable is to find a variable
that is associated with the variable we need to forecast and easier to predict.

In many applications, we cannot rely on finding a suitable leading variable and
have to try other methods. A second approach, common in marketing, is to use
information about the sales of similar products in the past. The in- fluential
Bass diffusion model is based on this principle. A third strategy is to make
extrapolations based on present trends continuing and to implement adaptive
estimates of these trends. The statistical technicalities of forecast- ing are
covered throughout the book, and the purpose of this chapter is to introduce the
general strategies that are available.

 

### Section 3.3 Building approvals and building activity time series 

The Australian Bureau of Statistics publishes detailed data on building
approvals for each month, and, a few weeks later, the Building Activity
Publication lists the value of building work done in each quarter.

The data in the file “ApprovActiv.dat" are the total dwellings approved per
month, averaged over the past three months, labelled “Approvals”, and the value
of work done over the past three months (chain volume measured in millions of
Australian dollars at the reference year 2004–05 prices), labelled “Activity”,
from March 1996 until September 2006.

We start by reading the data into R and then construct time series objects and
plot the two series on the same graph using “ts.plot"

 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Build.dat <- read.table('ApprovActiv.dat.txt', header=T)
head(Build.dat)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Approvals Activity

1    9988.0   5747.0

2   10320.3   6388.8

3   10682.3   6715.6

4   11086.7   7048.2

5   11604.0   6600.4

6   11861.0   6919.6

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
App.ts <- ts(Build.dat$Approvals, start = c(1996,1), freq=4)
plot(App.ts)

Act.ts <- ts(Build.dat$Activity, start = c(1996,1), freq=4)
plot(Act.ts)

ts.plot(App.ts, Act.ts, lty = c(1,3))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

In the figure below (Fig. 3.1 in the book), we can see that the building
activity tends to lag one quarter behind the building approvals, or equivalently
that the building approvals ap- pear to lead the building activity by a quarter.

![](<Copertwait - Chapter 3.images/WTuMNL.jpg>)

The *cross-correlation function*, which is abbreviated to **ccf**, can be used
to quantify this relationship. A plot of the *cross-correlation function*
against *lag* is referred to as a “**cross-correlogram**".

 

### Cross-correlation between building approvals and activity 

The “ts.union" function binds time series with a common frequency, padding with
‘NA’s to the union of their time coverages. If “ts.union" is used within the
**acf** command, R returns the correlograms for the two variables and the
cross-correlograms in a single figure.

 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
acf(ts.union(App.ts, Act.ts))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

![](<Copertwait - Chapter 3.images/Qzsoxa.jpg>)

 

In the figure above (Figure 3.2 in the book), the **acfs** for x and y are in
the upper left and lower right frames, respectively, and the **ccfs** are in the
lower left and upper right frames. The time unit for lag is one year, so a
correlation at a lag of one quarter appears at 0.25. If the variables are
independent, we would expect 5% of sample correlations to lie outside the dashed
lines. Several of the cross-correlations at negative lags do pass these lines,
*indicating that the approvals time series is leading the activity. *

 

Numerical values can be printed using the print() function, and are 0.432,
0.494, 0.499, and 0.458 at lags of 0, 1, 2, and 3, re-spectively (we seem to be
particularly focused on the lower left ccf, Act.ts \~ App.ts:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(acf(ts.union(App.ts, Act.ts)))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

>   Autocorrelations of series ‘ts.union(App.ts, Act.ts)’, by lag

>    

>   , , App.ts

>    

>   App.ts         Act.ts

>   1.000 ( 0.00)  0.432 ( 0.00)\*

>   0.808 ( 0.25)  0.494 (-0.25)\*

>   0.455 ( 0.50)  0.499 (-0.50)\*

>   0.138 ( 0.75)  0.458 (-0.75)\*

>   -0.057 ( 1.00)  0.410 (-1.00)

>   -0.109 ( 1.25)  0.365 (-1.25)

>   -0.073 ( 1.50)  0.333 (-1.50)

>   -0.037 ( 1.75)  0.327 (-1.75)

>   -0.050 ( 2.00)  0.342 (-2.00)

>   -0.087 ( 2.25)  0.358 (-2.25)

>   -0.122 ( 2.50)  0.363 (-2.50)

>   -0.174 ( 2.75)  0.356 (-2.75)

>   -0.219 ( 3.00)  0.298 (-3.00)

>   -0.196 ( 3.25)  0.218 (-3.25)

>    

>   , , Act.ts

>    

>   App.ts         Act.ts

>   0.432 ( 0.00)  1.000 ( 0.00)

>   0.269 ( 0.25)  0.892 ( 0.25)

>   0.133 ( 0.50)  0.781 ( 0.50)

>   0.044 ( 0.75)  0.714 ( 0.75)

>   -0.002 ( 1.00)  0.653 ( 1.00)

>   -0.034 ( 1.25)  0.564 ( 1.25)

>   -0.084 ( 1.50)  0.480 ( 1.50)

>   -0.125 ( 1.75)  0.430 ( 1.75)

>   -0.139 ( 2.00)  0.381 ( 2.00)

>   -0.148 ( 2.25)  0.327 ( 2.25)

>   -0.156 ( 2.50)  0.264 ( 2.50)

>   -0.159 ( 2.75)  0.210 ( 2.75)

>   -0.143 ( 3.00)  0.157 ( 3.00)

>   -0.118 ( 3.25)  0.108 ( 3.25)

 

Note: the lags start at 0 and go forward or backward, according to the plot.

The ccf can be calculated for any two time series that overlap, but if they both
have trends or similar seasonal effects, these will dominate (Exercise 1). It
may be that common trends and seasonal effects are precisely what we are looking
for, but the population ccf is defined for stationary random processes and it is
usual to remove the trend and seasonal effects before investigating
cross-correlations.

 

Below, we look at the ccf’s when we decompose the time series and look at the
ccf of the random component. Here we remove the trend using decompose, which
uses a centred moving average of the four quarters (see Fig. 3.3). We will
discuss the use of ccf in later chapters.

 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
app.ran <- decompose(App.ts)$random
app.ran.ts <- window (app.ran, start = c(1996, 3) )
act.ran <- decompose (Act.ts)$random
act.ran.ts <- window (act.ran, start = c(1996, 3) )

acf(ts.union(na.omit(app.ran.ts, act.ran.ts)))
ccf(na.omit(app.ran.ts), na.omit(act.ran.ts))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print(acf(ts.union(na.omit(app.ran.ts), na.omit(act.ran.ts)))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

![](<Copertwait - Chapter 3.images/IfJj4L.jpg>)

>   Autocorrelations of series ‘ts.union(na.omit(app.ran.ts),
>   na.omit(act.ran.ts))’, by lag

>    

>   , , na.omit(app.ran.ts)

>    

>   na.omit(app.ran.ts) na.omit(act.ran.ts)

>   1.000 ( 0.00)       0.144 ( 0.00)

>   0.427 ( 0.25)       0.699 (-0.25)

>   -0.324 ( 0.50)       0.497 (-0.50)

>   -0.466 ( 0.75)      -0.164 (-0.75)

>   -0.401 ( 1.00)      -0.336 (-1.00)

>   -0.182 ( 1.25)      -0.124 (-1.25)

>   0.196 ( 1.50)      -0.031 (-1.50)

>   0.306 ( 1.75)      -0.050 (-1.75)

>   0.078 ( 2.00)      -0.002 (-2.00)

>   -0.042 ( 2.25)      -0.087 (-2.25)

>   0.078 ( 2.50)      -0.042 (-2.50)

>   0.027 ( 2.75)       0.272 (-2.75)

>   -0.226 ( 3.00)       0.271 (-3.00)

>    

>   , , na.omit(act.ran.ts)

>    

>   na.omit(app.ran.ts) na.omit(act.ran.ts)

>   0.144 ( 0.00)       1.000 ( 0.00)

>   -0.380 ( 0.25)       0.240 ( 0.25)

>   -0.409 ( 0.50)      -0.431 ( 0.50)

>   -0.247 ( 0.75)      -0.419 ( 0.75)

>   0.084 ( 1.00)      -0.037 ( 1.00)

>   0.346 ( 1.25)       0.211 ( 1.25)

>   0.056 ( 1.50)       0.126 ( 1.50)

>   -0.187 ( 1.75)      -0.190 ( 1.75)

>   0.060 ( 2.00)      -0.284 ( 2.00)

>   0.142 ( 2.25)       0.094 ( 2.25)

>   -0.080 ( 2.50)       0.378 ( 2.50)

>   -0.225 ( 2.75)       0.187 ( 2.75)

>   -0.115 ( 3.00)      -0.365 ( 3.00)

 

 

The ccf function produces a single plot, shown above (Figure 3.4 in book), and
again shows the lagged relationship. The Australian Bureau of Statistics
publishes the building approvals by state and by other categories, and specific
sectors of the building industry may find higher correlations between demand for
their products and one of these series than we have seen here

 

### 3.4.1 Exponential smoothing 

Our objective is to predict some future value xn+k given a past history {x1, x2,
. . . , xn} of observations up to time n. In this subsection we assume there is
no systematic trend or seasonal effects in the process, or that these have been
identified and removed.

 

### Complaints to a motoring organisation 

The number of letters of complaint received each month by a motoring organ-
isation over the four years 1996 to 1999 are available on the website. At the
beginning of the year 2000, the organisation wishes to estimate the current
level of complaints and investigate any trend in the level of complaints. We
should first plot the data, and, even though there are only four years of data,
we should check for any marked systematic trend or seasonal effects.

 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Motor.dat <- read.table('motororg.dat.txt', header = T)
Comp.ts <- ts(Motor.dat$complaints, start = c(1996, 1), freq = 12)
plot(Comp.ts, xlab = "Time / months", ylab = "Complaints")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

According to the book, "There is no evidence of a systematic trend or seasonal
effects, so it seems reasonable to use exponential smoothing for this time
series.” When I decompose the time series, it looks like there is a trend to me!
I’ll look at the book example, and also apply to code to the random (de-trended
& de-seasonalized) time series as well.

 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Comp.ts.decomp <- decompose(Comp.ts)
plot(Comp.ts.decomp) 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

Exponential smoothing is a special case of the Holt-Winters algorithm, which we
introduce in the next section, and is implemented in R using the HoltWinters
function with the additional parameters set to 0. If we do not specify a value
for α, R will find the value that minimises the one-step-ahead prediction error.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Comp.hw1 <- HoltWinters(Comp.ts, beta = 0, gamma = 0)
Comp.hw1
plot(Comp.hw1)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

I’m not seeing that this is working out…

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Comp.hw2 <- HoltWinters(Comp.ts, alpha=0.2, beta = 0, gamma = 0)
Comp.hw2
plot(Comp.hw2)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

My Comp.hw1 looks identical to my Comp.hw2...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
plot(Comp.hw1, lwd=3)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

Ok, my Holt-Winters forecast for the AirPassengers AP series looks to match what
is in the book:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AP.hw <- HoltWinters(AP, seasonal = "mult")
plot(AP.hw)
AP.predict <- predict(AP.hw, n.ahead = 4 * 12)
ts.plot(AP, AP.predict, lty = 1:2)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

![](<AirPassengersHoltWinters.png>)

And:

![](<AP_HoltWinters_Forecast.png>)

The estimates of the model parameters, which can be obtained from AP.hw\$alpha,
AP.hw\$beta, and AP.hw\$gamma, are αˆ = 0.274, βˆ = 0.0175, and γˆ = 0.877.

 

It should be noted that the extrapolated forecasts are based entirely on the
trends in the period during which the model was fitted and would be a sensible
prediction assuming these trends continue. Whilst the extrapolation in Figure
3.12 looks visually appropriate, unforeseen events could lead to completely
different future values than those shown here.

 
