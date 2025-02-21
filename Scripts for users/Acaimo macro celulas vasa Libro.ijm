///////////////////////////////////////////////////////////////////////////////////////////////
/* Author: Alejandro Campoy-López
 * Microscopy Unit (CABD)
 * Date: 10.11.2021
 * 	
 * Description: Counting negative nuclei
 * 
 * Input: Folder containing Z-stacks to be processed
 * Output: Processed images and csv file with counted elements
 * 
 *///////////////////////////////////////////////////////////////////////////////////////////////

// select the folder
dir = getDirectory("Select folder containing tiff images");
list= getFileList (dir);
dir_resultados = createFolder(dir, "Processed");
print("Image;Nuclei"); // header of output file

// loop to process all images
	for (j=0; j<list.length; j++){ 

		if (endsWith(list[j], ".tif")){ // conditional only for tiff files

			open(dir+list[j]);
			slices = nSlices;
			title =  getTitle();
			rename("original");
			original = getImageID();
			getPixelSize(unit, pw, ph, pd);
			run("Properties...", "frames=1 pixel_width=1 pixel_height=1 voxel_depth=6.5"); // Make the image dimensionless to facilitate the use of different plugins, which require size parameters in different units. IT IS IMPORTANT TO KEEP THE XY-Z RATIO
			run("Duplicate...", "duplicate");
			rename("duplicated");
			duplicated = getImageID();
			run("Gaussian Blur 3D...", "x=2 y=2 z=1");
			setBatchMode(true); // to avoid opening images

			// for loop to process every slice
			for (i = 0; i < slices; i++) {
				selectImage(duplicated);
				setSlice(i+1);
				run("Enhance Local Contrast (CLAHE)", "blocksize=40 histogram=200 maximum=4.1 mask=*None*"); 
				run("Gray Scale Attribute Filtering", "operation=[Bottom Hat] attribute=Area minimum=1800 connectivity=8"); 
			    rename("clahe+attributeFilt "+(i+1));
				temp1 = getImageID();
				}

			// To put all images together as stack:
			run("Images to Stack", "name=Stack title=[clahe+attributeFilt ] use");
			setBatchMode(false);

			// 3D morphological filtering
			run("Morphological Filters (3D)", "operation=Opening element=Ball x-radius=8 y-radius=8 z-radius=2");


			// Finally we count the elements and print the result
			run("3D Objects Counter", "threshold=6 slice=31 min.=100 max.=21325752 statistics");
			rename("Stack_binary");
			print(title+";"+getValue("results.count"));

			// Generation of the output image
			run("Merge Channels...", "c1=[original] c2=[Stack_binary] create ignore");
			Stack.setChannel(2); // The signal channel in our microscopy setup (arrange accordingly)
			resetMinAndMax();
			run("Green");
			run("Select None");
			rename("processed_"+title); 
			saveAs("Tiff", dir_resultados+title);
			run("Close All");
			run("Clear Results");
			}
		}

// print and save results
selectWindow("Log");
saveAs("Text", dir_resultados+"Resultados.csv");
print("Macro finished");



//Auxiliary actions

function createFolder(dir, name) {
	mydir = dir+name+File.separator;
	File.makeDirectory(mydir);
	if(!File.exists(mydir)){
		print("Unable to create the folder");
	}
	return mydir;
}