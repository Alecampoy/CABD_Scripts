roiManager("reset");
run("3D Manager");
Ext.Manager3D_Reset();
print("\\Clear");
close("*");
run("Collect Garbage");
run("Clear Results");

dir = getDirectory("Selecciona el directorio con las imagnes individuales en tiff");
list= getFileList (dir);
dir_resultados = createFolder(dir, "Processed_thres manual");

for (j=0; j<list.length; j++){ 
	
run("Collect Garbage");
//condicional para el canal VERDE	
if (endsWith(list[j], ".tif")){ 	
	open(dir+list[j]);
	title =  getTitle();
	rename("original");
	original = getImageID();
	run("Split Channels");
	selectImage("C4-original");
	stack_to_segment = getTitle();

// segmentacion manual del botton_hat _______

run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();
Ext.CLIJ2_pushCurrentZStack(stack_to_segment);
Ext.CLIJ2_differenceOfGaussian3D(stack_to_segment, image_difference_of_gaussian3d_3, 2.5, 2.5, 1, 14, 14, 7);
Ext.CLIJ2_pull(image_difference_of_gaussian3d_3);
rename("Stack_after_DoG");
// segmentacion
run("Duplicate...", "title=stack_to_mask duplicate");
//manualmente
//run("Threshold...");  	 // open Threshold tool
//msg = "Use the \"Threshold\" tool to\nadjust the threshold, then click \"OK\".";
//waitForUser(msg);
//getThreshold(lower, upper);
//wait(50);
//setThreshold(lower, upper);
//wait(50);
//run("Convert to Mask", "background=Dark black");
run("3D Simple Segmentation", "seeds=None low_threshold=5 min_size=500 max_size=60001");
selectImage("Seg"); 
segment3D_opening = getImageID();
run("3D Manager");
Ext.Manager3D_AddImage();
wait(50);
Ext.Manager3D_Measure();
Ext.Manager3D_SaveResult("M",dir_resultados+title+"_segment.csv");
Ext.Manager3D_CloseResult("M");
Ext.Manager3D_Reset();
close("Bin");
selectImage(segment3D_opening);
setThreshold(1, 65535, "raw"); // to create a mask from the Seg segmented and filtered image
run("Convert to Mask", "background=Dark black");
rename("stack_bin_segment");


// guardar results
run("Merge Channels...", "c1=[C1-original] c2=[stack_bin_segment] c6=[Stack_after_DoG] create ignore");
Stack.setChannel(2);
resetMinAndMax();
saveAs("Tiff", dir_resultados+title);
print("____finished___ Thresh: noo"+j+" ___ " + title);


run("Close All");
run("Clear Results");


}}

//selectWindow("Log");
//saveAs("Text", dir_resultados+"Resultados.csv");
print("terminado");
selectWindow("Log");
saveAs("Text", dir_resultados+"Log.txt");



//Functions

function createFolder(dir, name) {
	mydir = dir+name+File.separator;
	File.makeDirectory(mydir);
	if(!File.exists(mydir)){
		print("Unable to create the folder");
	}
	return mydir;
}



//slices = nSlices;
//duplicado = getImageID();
//for (i = 0; i < slices; i++) {
//	selectImage(duplicado);
//	setSlice(i+1);
//	//run("Enhance Contrast...", "saturated=0.03 normalize");
//	// run("Enhance Local Contrast (CLAHE)", "blocksize=75 histogram=80 maximum=3.3 mask=*None*"); // ANTERIOR 3.2
//	//run("Enhance Local Contrast (CLAHE)", "blocksize=80 histogram=110 maximum=2.8 mask=*None*"); // ANTERIOR 3.2
//	run("Gray Scale Attribute Filtering", "operation=[Bottom Hat] attribute=Area minimum=1100 connectivity=8"); // ANTERIOR 1250
//    rename("clahe+attributeFilt "+(i+1));
//	temp1 = getImageID();
//}
//run("Images to Stack", "name=Stack title=[clahe+attributeFilt ] use");
/*setAutoThreshold("Default dark");
//run("Threshold...");
setAutoThreshold("IsoData dark");
setOption("BlackBackground", false);
run("Convert to Mask", "method=IsoData background=Dark calculate");
*/
//run("3D Objects Counter", "threshold=8 slice=31 min.=600 max.=70000 statistics"); //nuevos filtros de tamaño, hacer tambien que se eliminen los de los bordes y usar 3Dmanager
