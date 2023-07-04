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


//Seleccionamos las medidas deseadas
run("Set Measurements...", "area mean min centroid center perimeter bounding fit shape feret's area_fraction stack redirect=None decimal=2");

//Comienza un loop for para todas las imagenes en la carpeta, se abre para cada imagen verde
for (i=0; i<list.length; i++){ 
//condicional para el canal VERDE	
if (endsWith(list[i], "czi")){ 				

//Open green channel image
title=list[i];
run("Bio-Formats Importer", "open=["+dir+title+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

run("Median...", "radius=2");
run("Remove Outliers...", "radius=120 threshold=200 which=Bright");
run("Enhance Contrast...", "saturated=0.6");
setAutoThreshold("Yen");
//getThreshold(lower, upper);
//setThreshold(lower, upper+700);
setOption("BlackBackground", true);
run("Convert to Mask");
run("Watershed");

run("Analyze Particles...", "size=0.35-2.10 show=Masks display exclude add");

roiManager("Save", dir+title+"_RoiSet.zip");
run("Bio-Formats Importer", "open=["+dir+title+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
run("RGB Color");
setForegroundColor(255, 255, 0);
roiManager("show all");
roiManager("draw");
saveAs("Tiff", dir+title+".tif");
roiManager("delete");
run("Close All");

}
}
selectWindow("Results");
saveAs("Results", dir+"Results.csv");