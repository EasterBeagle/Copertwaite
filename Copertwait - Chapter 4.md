---
title: ""
---

Basic Stochastic Models — Chapter 4
-----------------------------------

So far, we have considered two approaches for modelling time series.

 

The first is based on an assumption that there is a fixed seasonal pattern about
a trend. We can estimate the trend by local averaging of the deseasonalised
data, and this is implemented by the R function **decompose**. The second
approach allows the seasonal variation and trend, described in terms of a level
and slope, to change over time and estimates these features by exponentially
weighted averages. We used the **HoltWinters** function to demonstrate this
method.

 

When we fit mathematical models to time series data, we refer to the
discrepancies between the fitted values, calculated from the model, and the data
as a *residual error series*.

 

If our model encapsulates most of the deterministic features of the time series,
our residual error series should appear to be a realisation of independent
random variables from some probability distribution i.e., *should appear to be
random & described adequately by a pdf model*.

 

**However, we often find that there is some structure in the residual error
series**, such as consecutive errors being positively correlated, **which we can
use to improve our forecasts** and make our simulations more realistic. We
assume that our residual error series is stationary, and in Chapter 6 we
introduce models for stationary time series.

 

**Since we judge a model to be a good fit if its residual error series appears
to be a realisation of independent random variables**, it seems natural to build
models up from a model of independent random variation, known as *discrete white
noise*. The name ‘white noise’ was coined in an article on heat radiation
published in Nature in April 1922, where it was used to refer to series that
contained all frequencies in equal proportions, analogous to white light. The
term purely random is sometimes used for white noise series. In §4.3 we define a
fundamental non-stationary model based on discrete white noise that is called
the **random walk**. It is sometimes an adequate model for financial series and
is often used as a standard against which the performance of more complicated
models can be assessed.

 

From p. 68 in the book:

### 4.2 White noise

4.2.1 Introduction

A residual error is the difference between the observed value and the model
predicted value at time t.

If we suppose the model is defined for the variable yt and yhatt is the value
predicted by the model, the residual error $x_{t}$ is

$$
x_{t} = y_{t} - \hat{y}_{t} 
$$

As the residual errors occur in time, they form a time series: \$x\_{1}, x\_{2},
. . . , x{n}\$.

In Chapter 2, we found that features of the historical series, such as the trend
or seasonal variation, are reflected in the correlogram. Thus, if a model has
accounted for all the serial correlation in the data, the residual series would
be serially uncorrelated, so that a correlogram of the residual series would
exhibit no obvious patterns. This ideal motivates the following definition.

 

4.2.2 Definition

A time series {\$w\_{t} : t = 1,2,...,n} is discrete white noise (DWN) if the
variables w\_{1}, w\_{2}, . . . , w\_{n} are independent and identically
distributed with a mean of zero. This implies that the variables all have the
same variance σ2 and Cor(wi,wj) = 0 for all i ̸= j. If, in addition, the
variables also follow a normal distribution (i.e., wt ∼ N(0,σ2)) the series is
called Gaussian white noise.

\*\*\*I’ll convert to LaTex later

4.2.3 Simulation in R

A fitted time series model can be used to simulate data. Time series simulated
using a model are sometimes called synthetic series to distinguish them from an
observed historical series.

 

Simulation is useful for many reasons. For example, simulation can be used to
generate plausible future scenarios and to construct confidence intervals for
model parameters (sometimes called bootstrapping). In R, simulation is usu- ally
straightforward, and most standard statistical distributions are simulated using
a function that has an abbreviated name for the distribution prefixed with an
‘r’ (for ‘random’).1 For example, rnorm(100) is used to simulate 100 independent
standard normal variables, which is equivalent to simulating a Gaussian white
noise series of length 100 (Fig. 4.1).

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set.seed(1)
w <- rnorm(100)
plot(w, type = "l")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 

Interestingly, when I make this into a ts object, and then decompose it, it
still pulls out a trend (non-sensical) and a seasonality. Hmmm….

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set.seed(5678)  
w <- rnorm(100)  
plot(w, type = "l")

w.ts <- ts(w, freq=12)
w.ts.decomp <- decompose(w.ts, type="additive")
plot(w.ts.decomp)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This also shows a trend and seasonality, but different. I think that
realistically, if you are describing something mathematically, you will likely
always be able to pull out some sort of seasonality…obviously, the trend is
simply averaging the previous 6 and next 6, so really just smoothing, so that
will always be there.

 

Simulation experiments in R can easily be repeated using the ‘up’ arrow on the
keyboard. For this reason, it is sometimes preferable to put all the commands on
one line, separated by ‘;’, or to nest the functions; for example, a plot of a
white noise series is given by plot(rnorm(100), type="l").

 

4.2.4 Second-order properties and the correlogram

The second-order properties of a white noise series {wt} are an immediate
consequence of the definition in §4.2.2. However, as they are needed so often in
the derivation of the second-order properties for more complex models, we
explicitly state them here:

 

μ w = 0

􏰶σ2 if k=0  
γk =Cov(wt,wt+k)= 0 if k̸=0 

The autocorrelation function follows as  
􏰶1 if k=0

ρk= 0 if k̸=0

(4.2)

(4.3)

 

Simulated white noise data will **not** have autocorrelations *that are exactly
zero* (when k  0) because of sampling variation. In particular, for a simu-
lated white noise series, it is expected that 5% of the autocorrelations will be
significantly different from zero at the 5% significance level, shown as dot-
ted lines on the correlogram. Try repeating the following command to view a
range of correlograms that could arise from an underlying white noise series. A
typical plot, with one statistically significant autocorrelation, occurring at
lag 7, is shown in Figure 4.2.

 

4.2.5 Fitting a white noise model

A white noise series usually arises as a residual series after fitting an
appropri- ate time series model. The correlogram generally provides sufficient
evidence,

−0.2 0.2

0.6 1.0

ACF

provided the series is of a reasonable length, to support the conjecture that
the residuals are well approximated by white noise.

The only parameter for a white noise series is the variance σ2, which is
estimated by the residual variance, adjusted by degrees of freedom, given in the
computer output of the fitted model. If your analysis begins on data that are
already approximately white noise, then only σ2 needs to be estimated, which is
readily achieved using the **var** function.

 

4.3 Random walks

 

4.3.1 Introduction

In Chapter 1, the exchange rate data were examined and found to exhibit
stochastic trends. A random walk often provides a good fit to data with
stochastic trends, although even better fits are usually obtained from more
general model formulations, such as the ARIMA models of Chapter 7.

 

4.3.2 Definition

Let {\$x\_{t}\$} be a time series. Then {\$x\_{t}\$} is a random walk if

$x_{t} = x_{t-1} - w_{t}$

where {\$w\_{t}\$} is a white noise series. Substituting xt−1 = xt−2+wt−1 in
Equation (4.4) and then substituting for xt−2, followed by xt−3 and so on (a
process known as ‘back substitution’) gives:

xt =wt +wt−1 +wt−2 +... (4.5) In practice, the series above will not be infinite
but will start at some time

t = 1. Hence,

xt =w1 +w2 +...+wt (4.6)

Back substitution is used to define more complex time series models and also to
derive second-order properties. The procedure occurs so frequently in the study
of time series models that the following definition is needed.

$$
 w_{n}
$$

$w_{n}$ — just writing in a “$” Texts interprets that as a $, and renders it as
\$ when exporting it to .txt.

\\$x_{t}\$

 

4.3.6 The difference operator

Differencing adjacent terms of a series can transform a non-stationary series to
a stationary series. For example, if the series {xt} is a random walk, it is
non-stationary. However, from Equation (4.4), the first-order differences of
{xt} produce the stationary white noise series {wt} given by xt − xt−1 = wt.
