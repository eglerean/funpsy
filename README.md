#FUNPSY (FUNctional magnetic resonance imaging Phase SYnchronization)

## What is it?
A simple collection of Matlab routines to 
- convert BOLD time series into phase time series after band-pass filtering and Hilbert transform
- compute instantaneous intersubject phase synchronization (an instantaneous measure of similarity between a group of subjects undergoing same stimulation)
- compute instantaneous dynamic functional connectivity consistent across subjects undergoing same stimulation

## How to cite and more details
Please see:
Glerean, E., Salmi, J., Lahnakoski, J.M., Jääskeläinen, I.P., Sams, M. (2012). [Functional Magnetic Resonance Imaging Phase Synchronization as a Measure of Dynamic Functional Connectivity](http://online.liebertpub.com/doi/abs/10.1089/brain.2011.0068?url_ver=Z39.88-2003&rfr_id=ori:rid:crossref.org&rfr_dat=cr_pub%3dpubmed). Brain connectivity 2(2): 91-101. doi:10.1089/brain.2011.0068

## How it has been used
See example of the tool in action in these papers:
- Nummenmaa L., Smirnov D., Lahnakoski J., Glerean E., Jääskeläinen I.P., Sams M., Hari R. (2013)  Mental Action Simulation Synchronizes Action-Observation Circuits Across Individuals. Journal of Neuroscience doi:10.1523/JNEUROSCI.0352-13.2014 
- Nummenmaa L., Saarimäki H.; Glerean E.; Gotsopoulos A.; Jääskeläinen I.P.; Hari R.; Sams M. (2014) Emotional Speech Synchronizes Brains Across Listeners And Engages Large-Scale Dynamic Brain Networks. Neuroimage doi:10.1016/j.neuroimage.2014.07.063 

## Documentation

### Installation
The code is managed with GIT and can be downloaded at https://github.com/eglerean/funpsy


### How to prepare your data
Funpsy currently works with data from experiments were all subjects are undergoing the same stimulation in sync (e.g. watching a feature film). It is an extension of methods such as intersubject correlation (https://code.google.com/p/isc-toolbox/) with the added temporal dimension. The phase synchrony method has however also been used successfully at rest with real data and models (see for example http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1004100).

The toolbox has been tested with data preprocessed following the FEAT FSL pipeline with coregistration to the 2mm MNI 152 template. Other spatial resolutions or volume sizes are allowed as long as the user provides a matching mask of voxels of interests of the same size of the data.

### How to run it
The easiest way is for you to open funpsy_demo.m and look at the comments. Just run funpsy_demo with your dataset and parameters of choice to obtain all the results.

### To-dos
Move and extend the documentation present at funpsy_demo.m into the subsections below.

- Inputting the data
- Selecting a bandpass filter
  TR is important!

- Intersubject phase synchronization
- Dynamic functional connectivity with seed based phase synchronization (SBPS)
- Intersubject SBPS
- How to prepare your ROIs
- Statistics
- Output formats
- Group based analysis
- Model based analysis (GLM)

## Development status

### Status of current development
Added more atlases for connectivity analysis. Currently working on a function for group comparisons (i.e. is group A more in-synch than group B) and model based analysis (general linear model of time series of synchronization). A small "how to" has been added to wiki pages.

### Next in the pipeline
- Parallel computing and optimizing permutation tests
- Add more atlases for ROIs (UCLA, CC200 and CC400)

###Future
Python version of the code (send an email if you want to help!)
