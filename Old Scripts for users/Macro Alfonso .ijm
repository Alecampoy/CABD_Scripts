///////////////////////////////////////////////////////////////////////////////////////////////
/* Name: DVA	
 * Author: Ale Campoy
 * Microscopy Unit (CABD)
 * Date: 23.11.2018
 * User: Alfonso 
 * 
 * GFP, m-Cherry & DAPI
 * Corregido para el tercer canal
 * 	
 * Description: Makes the Z proyection of every channel and then merge them into a tif image
 * 
 * Input: folder with images from delta vision .dv
 * Output: .tif files of 1 channel and time
 * 
 *///////////////////////////////////////////////////////////////////////////////////////////////

//SELECT FOLDER & GET LIST OF IMAGES

dir = getDirectory("Selecciona el directorio con las imagenes a tratar");
list= getFileList (dir);

//SPECIFY RESULTS FOLDER
myDir = createFolder(dir, "Processed_images");

//Calculate number of images
images = 0;
for (i=0; i<list.length; i++) {
      if (endsWith(list[i], ".dv")){
      	images++;
      }
};

print("Numero de imagenes a procesar: "+images);


//START LOOP TO ANALYZE ALL IMAGES IN SELECTED FOLDER IF THOSE ARE .dv
for (i=0; i<list.length; i++){ 
	if (endsWith(list[i], ".dv")){
		
//Open and get data
title=list[i];
run("Bio-Formats Importer", "open=["+dir+title+"] color_mode=Default view=Hyperstack stack_order=XYCZT");
getDimensions(width, height, channels, slices, frames);

if (channels>1){
run("Split Channels");


//Z-Stack for all channels
for (j=1; j<channels+1; j++) {
selectWindow("C"+j+"-"+title);
run("Z Project...", "projection=[Max Intensity] all");
}
}
else if (channels==1){
selectWindow(title);
run("Z Project...", "projection=[Max Intensity] all");
}

//Merge channels
	if (channels==2){
run("Merge Channels...", "c1=[MAX_C1-"+title+"] c2=[MAX_C2-"+title+"]");
	}
	else if (channels==3){
run("Merge Channels...", "c1=[MAX_C2-"+title+"] c2=[MAX_C3-"+title+"]  c3=[MAX_C1-"+title+"]");
	}
	else if (channels==1){
print("imagen: "+title+" solo contiene 1 canal")
	}
	else {
print("imagen erronea: "+title+" contiene más de 3 canales o no es adecuada");
	}

if (channels>1){
selectWindow("RGB");
name=substring(title, 0, lengthOf(title)-3);//Avoids .dv ending
saveAs("Tiff", myDir+name+".tif");
}
else if (channels==1){
selectWindow(title);
name=substring(title, 0, lengthOf(title)-3);
saveAs("Tiff", myDir+name+".tif");
}


//Clean images
while (nImages()>0) {
    selectImage(nImages());  
  run("Close");
	}
}
}

print("finiquitadas: "+images);






//Functions

function createFolder(dir, name) {
	mydir = dir+name+File.separator;
	File.makeDirectory(mydir);
	if(!File.exists(mydir)){
		exit("Unable to create the folder");
	}
	return mydir;
}
