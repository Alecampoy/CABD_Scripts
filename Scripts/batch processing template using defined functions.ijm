/*
 * Macro template to process multiple images in a folder
 */
#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix
// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input);


// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) //busca si hay alguna subcarpeta, pues esta sera un elemento de la lista anterior
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}


function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);
	print("Saving to: " + output);
	
	//Step1: Getting image information + Normalise the data name
	//get general information
	setBatchMode(true); //oculta el procesado
	open(input + File.separator + file);
	title = getTitle();
		
	//split channels and rename them
	run("Split Channels");
	selectWindow("C2-"+title);
	rename("Signal");
	selectWindow("C3-"+title);
	rename("Nuclei");

	
	//Step2: Prefilter nuclear image and make binary image
	selectWindow("Nuclei");
	//preprocessing of the grayscale image
	run("Median...", "radius=8");
	run("Subtract Background...", "rolling=200");
	//thresholding
	setAutoThreshold("Li dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	//postprocessing of binary image
	run("Fill Holes");
	
	

	//Step3: Retrieve the nuclei's boundaries
	//num = getNumber("minimum size", 400);
	num = 400;
	run("Analyze Particles...", "size="+num+"-Infinity add"); //add to ROI-Manager by running analyze particles

	//Step4: Retrieve the nuclear envelope's boundaries and save them in the ROI-Manager
	numberOfNuclei = roiManager("count");
	for(i=0; i<numberOfNuclei; i++){
		roiManager("Select", i);
		run("Enlarge...", "enlarge=-4");
		run("Make Band...", "band=5");
		roiManager("Update"); //original nucleus-ROI is replaced by nuclear envelope ROI
	}

	//Step 5: Measure signal in nuclear envelope's boundaries and save the result
 	run("Set Measurements...", "area mean redirect=None decimal=3"); //define the measurements
 	selectWindow("Signal");
 	roiManager("deselect");  //ensures that no ROI is selected
 	roiManager("Measure");	//measures active ROI or - if no ROI is selected - all ROIs

	//include imageName
	start_idx = nResults - numberOfNuclei; 
	stop_idx = nResults -1 ;
	for (i = start_idx ; i <= stop_idx; i++){
		setResult("image", i, title );
		
	}

	
	//save Roi-Manager
	path_prefix = output + File.separator + file;
	roiManager("save", path_prefix + "_rois.zip");

	//Step 6: Clean-up and prepare for batch-processing
	roiManager("reset");	
	run("Close All");
	//run("Clear Results");

}
