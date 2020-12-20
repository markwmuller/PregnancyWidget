# Pregnancy countdown

See it in the connect store [here](https://apps.garmin.com/en-US/apps/7439bd5d-f095-486e-a1d9-4d931ced7ebe).

![Default look](https://github.com/markwmuller/PregnancyWidget/blob/master/image.png)

# Title

Pregnancy countdown & statistics

#  Description (Maximum 4,000 Characters)

Are you excited about an incoming baby? Me too! 

This open source widget gives you some quick relevant info at a glance. I made it when I found out my wife was pregnant, and it was a way to turn my panic into semi-productivity. 

Enter the due date, and the widget calculates some basic statistics (progress, weight and length, remaining likelihood of miscarriage (early on) and likelihood of spontaneous birth soon (later on)). 

Privacy notice: No information ever leaves your device. 

Early on, it shows the probability of miscarriage (my biggest fear at the time). Numbers are from [here](https://spacefem.com/)

The baby length & mass are estimated too, with data taken from [here](https://www.babycenter.com/pregnancy/your-body/growth-chart-fetal-length-and-weight-week-by-week_1290794)

I also calculate the probability of spontaneous birth within the next seven days, using data estimated from ""The length of human pregnancy as calculated by ultrasonoggraphic measurement of the fetal biparietal diameter" by Kieler et al., Fig. 1.
Note "spontaneous birth" means not-induced; but for some bizarro reason does not include premature birth. It also excludes multiples.
See the python script `spontaneousPregnancyPDFApproximation.py` for info on how this data is manipulated. 
Specifically, I try to estimate the probability that the baby will be born in the next seven days, given that it has not been born yet.

The icon is from [here](https://www.freevector.com/pregnancy-icon-set-21124).

Of course, this widget should be treated as a bit of fun by an excited dad/mom-to-be; for any serious matters please refer to your healthcare professionals (not some random engineer). 


#  What’s New (Optional) (Maximum 4,000 Characters)
**V0.1**
* First public version



