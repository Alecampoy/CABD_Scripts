///////////////////////////////////////////////////////////////////////////////////////////////
/* Name: Peliculas
 * Author: Ale Campoy
 * Microscopy Unit (CABD)
 * Date: September.2019
 * User: Maria Jose 
 * 	
 * Description: Measure cells in bight field 
 * 
 * Input: folder with .tif images that are temporarly consecutive
 * Output: .csv with results
 * 
 *///////////////////////////////////////////////////////////////////////////////////////////////

//Borramos todo lo que pueda estar abierto
run("Close All");
run("Clear Results");
counts = roiManager("count");
if(counts !=0) {roiManager("delete");}


//Selecciona el directorio con las imagenes en .tiff
dir = getDirectory("Selecciona el directorio con las imagnes individuales en tiff");
list= getFileList (dir);

//calculamos el numero de imagenes
images = 0;
for (i=0; i<list.length; i++) {
      if (endsWith(list[i], ".tif")){
      	images++;
      }
};
print("Numero de imagenes en carpeta: "+images);

setBatchMode(true);


run("Set Measurements...", "area centroid center perimeter bounding fit shape median skewness kurtosis area_fraction display redirect=None decimal=2");


//Comienza un loop for para todas las imagenes en la carpeta, 
for (i=0; i<list.length; i++){ 	
if (endsWith(list[i], ".tif")){ 	

title_G=list[i];
open(dir+title_G);

run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.928 pixel_height=0.928 voxel_depth=1");
run("32-bit");
median = getValue("Median");
print(median);
changeValues(0, 5, median);

//run("Median...", "radius=1");
run("PHANTAST", "sigma=1.9 epsilon=0.05 new");
run("Invert");
//run("Morphological Filters", "operation=Closing element=Disk radius=3");
//prevWaterS = getImageID();
run("Watershed");

run("Analyze Particles...", "display add");


roiManager("Save", dir+title_G+"_RoiSet.zip");
roiManager("delete");

selectWindow("Results");
saveAs("Results", dir+title_G+"_datos.csv");
run("Clear Results");

/*
//variante con watershed
selectImage(prevWaterS);
run("Watershed");
run("Analyze Particles...", "display add");


roiManager("Save", dir+"WATERSHED"+title_G+"_RoiSet.zip");
roiManager("delete");
selectWindow("Results");
saveAs("Results", dir+"WATERSHED"+title_G+"_datos.csv");
run("Clear Results");
*/



run("Close All");
}
}

print("\\Terminado");

