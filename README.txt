### Project Description
This is rough Beta code for performing Austomated Static Threshold Perimetry using a Remote Eye-tracking (RE-ASTP)

It's currently very early days, but if you're interested in getting involved or discussing what we're doing, please send me an email: p.r.jones@ucl.ac.uk
	
### Quick Start: Setting up
1. Download the toolkit (using the link on the left) and unzip it into an appropriate directory (e.g., C:/Experiments/visfield)
2. Download and setup PsychToolbox
3. Add (including subdirectories) everything in ./visfield/run/toolkits
4. Run InstallIvis.m
5. For the zest algorithm, see ./visfield/run/code/+visfield/+zest/Examples.m
5. For a full example experiment, see ./visfield/run/visfield_v2_4_2.m 

### System Requirements
Hardware:
- The system has been developed using a Tobii EyeX eyetracker. However, it should be relatively straightforward to extend the system to work with other types of eyetracker (e.g., eyelink).
- Apart from the eyetracker, no specialised equipment is required. However, a modern graphics cards, a dual-monitor setup, and an ASIO compliant soundcard are recommended.
	
Software:
- Matlab 2012 or newer, running on Windows, Mac, or Linux (32 or 64 bit). Note that older versions of Matlab will not work, due to the heavy reliance on relatively modern, Object-Oriented features - sorry. See documentation for a full breakdown of proven systems.

### Keeping Up to date
Users familiar with Git can ensure that they are always using the most recent version by subscribing to the central repository, at: https://github.com/petejonze/visfield

---------------------------

**Q** I've noticed a bug in file x, what should I do?  
**A** E-mail and let me know. Better yet, fix it and send me a copy. Or sign up to Git to get direct access to the primary source code.


### Enjoy!
@petejonze  
10/02/2016





