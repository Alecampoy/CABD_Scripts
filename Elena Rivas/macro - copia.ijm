//Borramos todo lo que pueda estar abierto
run("Close All");
run("Clear Results");
counts = roiManager("count");
if(counts !=0) {roiManager("delete");}

//Selecciona el directorio con las imagenes 
dir = getDirectory("Selecciona el directorio con las imagnes");
list= getFileList (dir);

//calculamos el numero de imagenes
images = 0;
for (i=0; i<list.length; i++) {
      if (endsWith(list[i], "czi")){
      	images++;
      }
};
print("Numero de imagenes en carpeta: "+images);
setBatchMode(true);


//Seleccionamos las medidas deseadas
run("Set Measurements...", "area mean min centroid center perimeter bounding fit shape feret's area_fraction stack redirect=None decimal=2");

//Comienza un loop for para todas las imagenes en la carpeta, se abre para cada imagen verde
for (i=0; i<list.length; i++){ 
//condicional para el canal VERDE	
if (endsWith(list[i], "czi")){ 				

//Open green channel image
title=list[i];
run("Bio-Formats Importer", "open=["+dir+title+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");



run("Subtract Background...", "rolling=15 light");
run("Gaussian Blur...", "sigma=2");
run("Invert");
run("Enhance Contrast...", "saturated=0.5 normalize");
run("Unsharp Mask...", "radius=4 mask=0.60");


run("H_Watershed", "impin=["+title+"] hmin=7000.0 thresh=53000.0 peakflooding=100.0 outputmask=false allowsplitting=false");

setThreshold(0, 0);
setOption("BlackBackground", false);
run("Convert to Mask");
run("Invert");
run("Watershed");

run("Analyze Particles...", "size=50-240 show=Masks display exclude add");

roiManager("Save", dir+title+"_RoiSet.zip");
run("Bio-Formats Importer", "open=["+dir+title+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
run("RGB Color");
setForegroundColor(255, 255, 0);
roiManager("show all");
roiManager("draw");

imatiff = dir + "imagenes tiff\\";
File.makeDirectory(imatiff);
saveAs("Tiff", dir+title+".tif");
roiManager("delete");
run("Close All");

}
}
selectWindow("Results");
saveAs("Results", dir+"Results.csv");