#@ ImagePlus imp
#@ OUTPUT ImagePlus result

# this macro creates a labeled image from ROIs. execute with fiji and select python as language

from ij import IJ
from ij.plugin.frame import RoiManager

result = IJ.createImage("Labeling", "16-bit black", imp.getWidth(), imp.getHeight(), 1)
ip = result.getProcessor()
rm = RoiManager.getInstance()

for index, roi in enumerate(rm.getRoisAsArray()):
	ip.setColor(index+1)
	ip.fill(roi)

ip.resetMinAndMax()
IJ.run(result, "glasbey inverted", "")
