///////////////////////////////////////////////////////////////////////////////////////////////
/* Name: Cucumbershape segmentation
 * Author: Ale Campoy
 * Microscopy Unit (CABD)
 * Date: 23.04.2019
 * User: Luciano 
 * 	
 * Description: Measure morphology of WF and green channel	using threshold segmentation
 * 
 * Input: folder with .tif images where the channel is at the end of the filename
 * Output: folder with images where the shape is drawn and .csv with results
 * 
 *///////////////////////////////////////////////////////////////////////////////////////////////

//Borramos todo lo que pueda estar abierto
run("Close All");
run("Clear Results");
counts = roiManager("count");
if(counts !=0) {roiManager("delete");}

//Abre Dialogo donde introducir  parametros para la morpholib
Dialog.create("Parametros para la segmentacion del canal verde y para la segmentación morfologica del WF");
Dialog.addNumber("Treshold green intensity", 5750); 
Dialog.addNumber("Number of pixels gaussian blur", 3); 
Dialog.addNumber("Numero de canales", 3); 
Dialog.show(); 
gfpT = Dialog.getNumber();
gaussR = Dialog.getNumber(); 
canales = Dialog.getNumber(); 


//


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

//Seleccionamos las medidas deseadas
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display redirect=None decimal=2");


//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//	//

//Comienza un loop for para todas las imagenes en la carpeta, se abre para cada imagen verde
for (i=0; i<list.length; i++){ 
//condicional para el canal VERDE	
if (endsWith(list[i], "AF488_ORG.tif")){ 					//VERDE		
	
//Open green channel image
title_G=list[i];
open(dir+title_G);
run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.91 pixel_height=0.91 voxel_depth=1"); //correct units for celldiscoverer files
getDimensions(width, height, channels, slices, frames);

//segmentamos y creamos roi del canal verde
run("Gaussian Blur...", "sigma=3");
setThreshold(gfpT, 65535); // Threshold value introduced before
run("Convert to Mask");
run("Create Selection");
selection=selectionType();
if (selection !=-1){
roiManager("Add"); //se añade el roi VERDE
roiManager("select", 0);
roiManager("rename", "AF488 surface "+floor(i/canales+1));
open(dir+title_G); //vuelve a abrir la imagen inicial para realizar la medida sobre el roi generado
run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.91 pixel_height=0.91 voxel_depth=1");
roiManager("deselect");
roiManager("Measure");
roiManager("delete");
run("Close All");}
run("Close All");

//Abrimos la imagen WF para segmentarla y obtener parametros morfologicos

title_WF=substring(title_G, 0, lengthOf(title_G)-13);
title_WF=title_WF+"Bright_ORG.tif";
open(title_WF);
run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.91 pixel_height=0.91 voxel_depth=1");
getDimensions(width, height, channels, slices, frames);

//segmentamos y creamos roi del canal rojo
run("Subtract Background...", "rolling=50 light sliding");
run("Sharpen"); 
run("Enhance Contrast...", "saturated=0.2 normalize");
run("Remove Outliers...", "radius=2 threshold=20 which=Bright");
run("Gaussian Blur...", "sigma=gaussR");
run("Duplicate...", " ");
setAutoThreshold("IsoData no-reset");
//run("Threshold...");
run("Convert to Mask");
run("Fill Holes");
run("Analyze Particles...", "size=15000-Infinity show=Masks");
run("Remove Outliers...", "radius=10 threshold=50 which=Dark");
run("Morphological Filters", "operation=Erosion element=Disk radius=2");
run("Create Selection");
roiManager("Add");
roiManager("select", 0);
roiManager("rename", "WF surface "+floor(i/canales+1));
roiManager("measure");
close();


// Pinta el roi segmentado para comprobacion
open(dir+title_WF);
run("RGB Color");
setForegroundColor(255, 255, 0);
roiManager("Select", 0);
roiManager("Draw");
roiManager("reset");
//

carpeta = createFolder(dir, "resultados de la segmentacion WF");
saveAs(title_WF, carpeta+list[i]);
run("Close All");


}
}

//guardamos los resultados
selectWindow("Results");
saveAs("Results", dir+"results_threshold.csv");
print("finiquitado con exito");

// FIN // FIN // FIN // FIN // FIN // FIN 






//Functions

function createFolder(dir, name) {
	mydir = dir+name+File.separator;
	File.makeDirectory(mydir);
	if(!File.exists(mydir)){
		exit("Unable to create the folder");
	}
	return mydir;
}
