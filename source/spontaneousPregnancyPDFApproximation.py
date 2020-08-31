import numpy as np
import matplotlib.pyplot as plt


# did a piecewise fit of Fig 1 from "The length of human pregnancy as calculated by ultrasonoggraphic measurement 
#  of the fetal biparietal diameter", Kieler et al.
graphData = np.array([
    [-1000, 0],
    [25.5, 0],
    [46,8.2],
    [58.5,47.2],
    [75.5,0],
    [100000, 0]
    ])

#convert to days, and N:
graphData[:,0] = 220 + 80/77.2*graphData[:,0] #days
graphData[:,1] = 60/59*graphData[:,1]

#normalization constant for the approximation
# paper has N=865 pregnancies, we'll treat this as close enough.
graphData[:,1] /= 876.2624073881558175438


def pdf(d):
    for i in range(graphData.shape[0] -1):
        if d < graphData[i+1,0]:
            break
        
    x0 = graphData[i,0]
    x1 = graphData[i+1,0]
    y0 = graphData[i,1]
    y1 = graphData[i+1,1]
    return y0 + (d-x0)/(x1-x0)*(y1-y0)

days = np.arange(220, 320)
fig, ax = plt.subplots(2,1, sharex=True)
ax[0].plot(days, [pdf(d) for d in days])
# this looks similar enough to Fig 1, will take

#normalization constant (lazy Riemann sum):
yvals = np.array([pdf(d) for d in days])
print(np.sum(yvals))

# compute the mean and standard deviation (I'm lazy, so do this numerically)
mean = np.sum(np.array([d*pdf(d) for d in days]))
print(mean) #get 279.36 days, close enough to the given 280.6
std = np.sqrt(np.sum(np.array([(d-mean)**2*pdf(d) for d in days])))
print(std) #get 9.0 days, they give 9.7; I guess this is OK. 

#compute the cumulative distribution function, and center it at zero
cdf_data = np.zeros_like(graphData)
cdf_data[:,0] = graphData[:,0]
cdf_data[0,1] = 0
for i in range(cdf_data.shape[0]-1):
    #height--
    cdf_data[i+1, 1] = cdf_data[i, 1] + 0.5*(graphData[i+1,0]-graphData[i,0])*(graphData[i+1,1]+graphData[i,1])

print(cdf_data)
ax[1].plot(cdf_data[:,0], cdf_data[:,1], '-.')
ax[1].set_xlim([220,320])
plt.show()

#print for copying to mc file:
for i in range(cdf_data.shape[0]):
    print("  [{0}, {1}],".format(cdf_data[i,0], cdf_data[i,1]))
