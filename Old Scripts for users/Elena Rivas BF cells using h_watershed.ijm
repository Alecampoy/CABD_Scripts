///////////////////////////////////////////////////////////////////////////////////////////////
/* Author: Ale Campoy
 * Microscopy Unit (CABD)
 * Date: 06/07/23
 * User: Elena Rivas
 * 	
 * Description: Segments the bacteria from BF images and measure its morphological parameters
 * 
 * Input: Folder with the set of bright field images from Elyra-LSM880. Each condition is in a folder named with the condition.
 *
 * Method: Interactive Watershed Segmentation with seeds
 * 
 * Output: Segmented images in folder and result file
 * 
 *///////////////////////////////////////////////////////////////////////////////////////////////


// 0.0 Clean previous data in FIJI
run("Close All");
run("Clear Results");
print("\\Clear");
if(roiManager("count") !=0) {roiManager("delete");}

// 0.1 Set measurements
run("Options...", "iterations=1 count=1 black"); // Set black binary bckg
run("Set Measurements...", "area centroid perimeter fit shape feret's redirect=None decimal=2");
setForegroundColor(255, 255, 0);


// 1 Select the Folder with the files
dir = getDirectory("Select the folder with condition folders inside");
list = getFileList(dir); // list of condition - every condition is a folder
Results = createFolder(dir, "Results");


Start_time = getTime(); // to inform how long does it take to process the folder

for(f = 0; f<list.length; f++){ // Loop for the folder with folders inside. Every folder f is a condition
	if (File.isDirectory(dir+list[f])){
		dir_condicion = dir+list[f];
		condition = list[f];
		list_images = getFileList(dir_condicion);
		for (i=0; i<list_images.length; i++){ // Loop for files inside every folder
			if (endsWith(list_images[i], "czi")){
				title=list_images[i];
				condition_title= substring(condition, 0, lengthOf(condition)-1)+"_"+title;
// 2 Open and Process of every image
				run("Bio-Formats Importer", "open=["+dir_condicion+title+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
				original=getImageID();
				run("Duplicate...", "title=process");
				run("Subtract Background...", "rolling=15 light");
				run("Gaussian Blur...", "sigma=2");
				run("Invert");
				run("Enhance Contrast...", "saturated=0.5 normalize");
				run("Unsharp Mask...", "radius=4 mask=0.60");
				run("8-bit");
				run("H_Watershed", "impin=[process] hmin=36.0 thresh=166.0 peakflooding=100.0 outputmask=false allowsplitting=false"); //  hmin=6250.0 thresh=50500.0 para imagenes de 16 bits
				setThreshold(0, 0);
				setOption("BlackBackground", true);
				run("Convert to Mask");
				run("Invert");
				run("Watershed");
				run("Analyze Particles...", "size=30-200 show=Nothing exclude clear add"); // the particle size has been adjusted to pixel with conversion 1pixel = 0.1um
				// roiManager("Save", dir+title+"_RoiSet.zip");

// 3 Draws and save the results
				selectImage(original);
				roiManager("Measure");
				run("RGB Color");
				roiManager("show all");
				roiManager("draw");
				saveAs("Tiff", Results+condition_title+"_segm.tif");
				// csv results
				selectWindow("Results");
				saveAs("Results", Results+condition_title+"_Results.csv");

// clean and loop for images goes on
				roiManager("delete");
				run("Clear Results");
				run("Close All");
				
			}
		}
	}
}
setBatchMode(false);

// Macro is finished. Print time						
print("\\Clear");
print("Finito");
Finish_time = getTime();
Time_used = Finish_time - Start_time;
print("It took =", Time_used/1000, "second to finish the proccess");


//Functions
function createFolder(dir, name) {
	mydir = dir+name+File.separator;
	File.makeDirectory(mydir);
	if(!File.exists(mydir)){
		print("Unable to create the folder");
	}
	return mydir;
}
