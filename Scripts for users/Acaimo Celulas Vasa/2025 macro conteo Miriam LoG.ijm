roiManager("reset");
run("3D Manager");
Ext.Manager3D_Reset();
print("\\Clear");
close("*");
run("Collect Garbage");
run("Clear Results");

dir = getDirectory("Selecciona el directorio con las imagnes individuales en tiff");
list= getFileList (dir);
dir_resultados = createFolder(dir, "Processed");

for (j=0; j<list.length; j++){ 
	
run("Collect Garbage");
//condicional para el canal VERDE	
if (endsWith(list[j], ".tif")){ 	
	// GPU inicialization
	run("CLIJ2 Macro Extensions", "cl_device=");
	Ext.CLIJ2_clear();
	open(dir+list[j]);
	title =  getTitle();
	rename("original");
	original = getImageID();
	getPixelSize(unit, pw, ph, pd);
	run("Properties...", "frames=1 pixel_width=1 pixel_height=1 voxel_depth=6.5");
	run("Duplicate...", "duplicate");
	rename("duplicado");
	duplicado = getTitle();

	// procesado duplicado
	selectImage("duplicado");
	run("Enhance Contrast...", "saturated=0.55 normalize process_all use");
	//run("Median 3D...", "x=4 y=4 z=1");
	Ext.CLIJ2_push(duplicado);
	Ext.CLIJ2_median3DSphere(duplicado, duplicado_norm, 4, 4, 1);
	Ext.CLIJ2_pull(duplicado_norm);
	rename("duplicado_norm");
	
	// mascara para limpiar fuera
	run("Z Project...", "projection=[Max Intensity]");
	mask = getImageID();
	setAutoThreshold("Default dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Maximum...", "radius=5");
	run("Fill Holes");
	run("Analyze Particles...", "add");

//// clahe
//selectImage(duplicado_norm);
//slices = nSlices;
//for (i = 0; i < slices; i++) {
//	selectImage(duplicado_norm);
//	setSlice(i+1);
//	 run("Enhance Local Contrast (CLAHE)", "blocksize=59 histogram=250 maximum=1.6 mask=*None*"); // ANTERIOR 3.2
//}

	// bottom hat & medianGPU
	selectImage("duplicado_norm");
	print("creating bottom hat");
	run("Gray Scale Attribute Filtering 3D", "operation=[Bottom Hat] attribute=Volume min=8000 connectivity=6");
	rename("Stack_after_BottonHat");
	Stack_after_BottonHat = getTitle();
	Ext.CLIJ2_push(Stack_after_BottonHat);
	Ext.CLIJ2_median3DSphere(Stack_after_BottonHat, Stack_after_BottonHat_median, 2, 2, 1);
	Ext.CLIJ2_pull(Stack_after_BottonHat_median);
	rename("Stack_after_BottonHat_median");
	
	// realizo dos procesados diferentes del BottomHat
	run("Duplicate...", "title=stack_to_Log duplicate");
	stack_to_log =getImageID();
	// segmentacion
	run("Duplicate...", "title=stack_to_segment duplicate");
	stack_to_segment =getImageID();

// LoG______
selectImage(stack_to_log);
run("LoG 3D", "sigmax=2 sigmay=2 sigmaz=1 displaykernel=0 volume=1");
print("waiting till log3d is ready");
wait(1000*60*2.3);
run("Invert", "stack");
setThreshold(0.75, 1000000000000000000000000000000.0000);
run("Convert to Mask", "background=Dark black");
// limpieza fuera
roiManager("Combine");
setBackgroundColor(0, 0, 0);
run("Clear Outside", "stack");
// medida y segmentación de la mascara
run("3D Simple Segmentation", "seeds=None low_threshold=69 min_size=600 max_size=60001");
selectImage("Seg"); 
segment3D_log = getImageID();
run("3D Manager");
Ext.Manager3D_AddImage();
wait(50);
Ext.Manager3D_Measure();
Ext.Manager3D_SaveResult("M",dir_resultados+title+"_LoG.csv");
Ext.Manager3D_CloseResult("M");
Ext.Manager3D_Reset();
close("Bin");
selectImage(segment3D_log);
setThreshold(1, 65535, "raw"); // to create a mask from the Seg segmented and filtered image
run("Convert to Mask", "background=Dark black");
rename("stack_bin_log");


// segmentacion_______
selectImage(stack_to_segment);
run("CLIJ2 Macro Extensions", "cl_device=");
image_gpu_DoG = getTitle();
Ext.CLIJ2_pushCurrentZStack(image_gpu_DoG);
Ext.CLIJ2_differenceOfGaussian3D(image_gpu_DoG, image_difference_of_gaussian3d_3, 2, 2, 1, 14, 14, 10);
Ext.CLIJ2_pull(image_difference_of_gaussian3d_3);
run("Enhance Contrast...", "saturated=0.1 normalize process_all use");
setAutoThreshold("Intermodes dark");
setOption("BlackBackground", true);
run("Convert to Mask", "background=Dark black");
// limpieza fuera
roiManager("Combine");
setBackgroundColor(0, 0, 0);
run("Clear Outside", "stack");
run("3D Simple Segmentation", "seeds=None low_threshold=4 min_size=450 max_size=60001");
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
run("Merge Channels...", "c1=[original] c2=[stack_bin_segment] c3=[stack_bin_log] c6=[Stack_after_BottonHat_median] create ignore");
Stack.setChannel(2);
resetMinAndMax();
Stack.setChannel(3);
resetMinAndMax();
saveAs("Tiff", dir_resultados+title);
print("______finished " + title);


run("Close All");
run("Clear Results");
roiManager("reset");


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
