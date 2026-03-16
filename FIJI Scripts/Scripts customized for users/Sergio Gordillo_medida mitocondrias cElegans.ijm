/*
 * Macro para Sergio Gordillo en el que se segmenta manualmente la mitocondria de un slice de un gusano. 
 * Requiere un Roi de la región a cuantificar, que es donde se medirá 
 */


Threshold=34;
Thr_auto=true;


// setting
run("Close All");
run("Clear Results");
roiManager("reset");
run("Input/Output...", "jpeg=100 gif=-1 file=.tsv copy_column copy_row save_column save_row");
run("Options...", "black");

run("Set Measurements...", "area mean perimeter bounding fit shape feret's area_fraction display redirect=None decimal=3");
roiManager("reset");
setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);

// dir para las imagenes
dir = getDirectory("Selecciona un directorio con las imagenes"); // puedes poner un directorio fijo como en la siguiente linea y comentar esta
// directorio = "P:\CABD\Lab Peter & Marta Artal\Sergio medida mitocondrias\datos ejemplo procesado por celula";
list = getFileList(dir);  // lista con las imagenes dentro de la carpeta

if (Thr_auto == true) { // carpeta resultados
	Results = createFolder(dir, "Results_Thr_auto");
} else {
	Results = createFolder(dir, "Results_Thr_"+Threshold);
}

// Loop para abrir las imagenes una por una, solo si son tif
for (i=0; i<list.length-6; i++){
	if (endsWith(list[i], ".tif")){
		// 0. Open and get data
		title=list[i];
		open(dir+title);
		// guarda el roi de la celula
		roiManager("Add");
		roiManager("Select", 0);
		roiManager("Rename", "Area_pintada");
		imagen = getTitle();
		rename("original");
		run("Select None");
		
		// procesado
		run("Duplicate...", "title=to_process ignore");
		resetMinAndMax;
		//run("Tubeness", "sigma=0.50 use");
		run("8-bit");
		run("Bilateral Filter", "spatial=3 range=20");
		if (Thr_auto == true) {
			setAutoThreshold("Default dark");
			getThreshold(Threshold, upper);
		} else {
			setThreshold(Threshold, 255);
		}
		run("Convert to Mask");
		rename("mask");
		mask = getImageID();
		// limpia la mascara fuera de la célula
		roiManager("Select", 0);
		run("Clear Outside");
		run("Duplicate...", "title=to_skelet");
		to_skelet = getImageID();
		// copia para pintar el skeleton
		selectImage("original");
		roiManager("Select", 0);
		run("Duplicate...", "title=pintar_skelet");
		run("Clear Outside");
		pintar_skelet = getImageID();
		
		// guardo roi segmentacion, mido la mitocondria y guardo resultado
		selectImage(mask);
		run("Select None");
		run("Analyze Particles...", "size=4-Infinity pixel show=Masks exclude add composite");  // filtrado de elementos de menos de 4 pixeles
		run("Grays"); // eliminar // al comienzo de la linea si se desea en blanco y negro
		// saveAs("Tiff", dir+imagen+"_mask.tif");// guardar mascara
		roiManager("Save", Results+imagen+"_Roi_resultado_Thr"+Threshold+".zip"); 
		selectImage("original");
		roiManager("Measure");
		roiManager("show all without labels");
		run("Flatten");
		saveAs("Jpeg", Results+imagen+".jpg");
		selectWindow("Results");
		saveAs("Results", Results+imagen+"_Resultados.tsv");
		run("Clear Results");
		
		// analizo el skeleton
		selectImage(to_skelet);
		run("Grays");
		wait(80);
		run("Skeletonize (2D/3D)");
		run("Analyze Skeleton (2D/3D)", "prune=none calculate show"); // sin pruning
		selectWindow("Results");
		wait(50);
		saveAs("Results", Results+imagen+"_skeleton.tsv");
		run("Clear Results");
		selectWindow("Branch information");
		wait(50);
		saveAs("Results", Results+imagen+"_Branches_information.tsv");
		close(imagen+"_Branches_information.tsv");
		
		// Pinto el skeleton
		selectImage("Tagged skeleton");
		run("16_colors");
		run("Merge Channels...", "c1=pintar_skelet c5=[Tagged skeleton]");
		saveAs("Jpeg", Results+title+"_skeleton.jpg");
		
		// fin de macro por imagen
		close("*");
		roiManager("reset");
	}
}

print("Macro terminado");




	
//Functions

function createFolder(dir, name) {
	mydir = dir+name+File.separator;
	File.makeDirectory(mydir);
	if(!File.exists(mydir)){
		exit("Unable to create the folder");
	}
	return mydir;
}



