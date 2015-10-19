//  
// MP3 Teaport CS418
// HUANG Tianwei, Netid: thuang23
//  video link: https://www.youtube.com/watch?v=HVoKZ3w10L8
#include "StdAfx.h"
#include "SOIL.h"
#include <cmath>
#include <fstream>
#include <vector>
#include <cstring>
#include <stdio.h>
#include <stdlib.h>

#include <GL/glut.h>
#include <gl/GL.h>
#include <gl/GLU.h>


#include <ctime>
#define PI 3.1415926


struct texture
{
	float s;
	float t;
};

struct vertexNormal 
{
	float x;
	float y;
	float z;
};

struct Vertex
{
    float x;
    float y;
    float z;
	struct vertexNormal vn;
	struct texture text;
};

struct Face
{
    int index1;
    int index2;
    int index3;
};

//global variable
std::vector<Vertex> vertices;
std::vector<Face> faces;
GLuint	texture[2];			// Storage for text map and 
int textOn;
//bool envrOn;
float ymax;                 //for texture coordinate computation
int nFPS = 40;
float fRotateAngle = 0.f;
clock_t startClock=0,curClock;
long long int prevF=0,curF=0;

int LoadGLTextures()									// Load Bitmaps And Convert To Textures
{
	glGenTextures(2, texture);
	/* load an image file directly as a new OpenGL texture */
	texture[0] = SOIL_load_OGL_texture
		(
		"Texture/galaxy.bmp",
		SOIL_LOAD_AUTO,
		SOIL_CREATE_NEW_ID,
		SOIL_FLAG_INVERT_Y
		);


	texture[1] = SOIL_load_OGL_texture
		(
		"Texture/chess.bmp",
		SOIL_LOAD_AUTO,
		SOIL_CREATE_NEW_ID,
		SOIL_FLAG_INVERT_Y
		);
	

	/*
	if (textOn) 
	{
		glActiveTexture(GL_TEXTURE0);
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, texture[0]);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);


	}

	if (envrOn) 
	{
		glActiveTexture(GL_TEXTURE1);
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, texture[1]);
		glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
		glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	}
	*/
	
	/*
	glBindTexture(GL_TEXTURE_2D, texture[0]);
	

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_NEAREST); 
 
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
 
 
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL); 
 
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); 
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT); 
	*/
	
	

	


	return true;										// Return Success
}

void init(void)
{
	textOn = 0;
	//envrOn = false;
	ymax = 0;
	fRotateAngle = 0.f;
	if (!LoadGLTextures())								// Jump To Texture Loading Routine ( NEW )
	{
		return;									// If Texture Didn't Load Return FALSE
	}

	//glewInit();
	//glEnable(GL_TEXTURE_2D);


	glEnable(GL_DEPTH_TEST);
	// init your data, setup OpenGL environment here
	glClearColor(0.9,0.9,0.9,1.0); // clear color is gray		
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL); // uncomment this function if you only want to draw wireframe model
					// GL_POINT / GL_LINE / GL_FILL (default)
	
	glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);

    GLfloat white[] = {.8,.8,.8,1.0};
    GLfloat lpos[] = {5.0,10.0,0.0,0.0};

    glLightfv(GL_LIGHT0, GL_POSITION, lpos);
    glLightfv(GL_LIGHT0, GL_AMBIENT, white);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, white);
    glLightfv(GL_LIGHT0, GL_SPECULAR, white);
   
}

void calcText() 
{
	float theta;
	for(int i = 0; i < vertices.size(); i ++) 
	{
		theta = atan(vertices[i].z / vertices[i].x);
		vertices[i].text.s = (theta + PI) / 2 / PI;
		vertices[i].text.t = vertices[i].y / ymax;
		//vertices[i].text.s = vertices[i].x;
		//vertices[i].text.t = vertices[i].y;
	}

	return;
}


void parseVertex(char *line) {
	vertices.push_back(Vertex());

	sscanf(line, "v %f %f %f", &vertices.back().x, &vertices.back().y, &vertices.back().z);
	vertices.back().vn.x = vertices.back().vn.y = vertices.back().vn.z = 0.0;

	//update ymax
	if(vertices.back().y > ymax) 
	{
		ymax = vertices.back().y;
	}
	return;
}

void parseFace(char *line) 
{
	faces.push_back(Face());

	sscanf(line, "f %d %d %d", &faces.back().index1, &faces.back().index2, &faces.back().index3);
	return;
}

void parseLine(char *line) {
	if(!strlen(line))
	{
		return;
	}

	char *lineType;
	lineType = strtok(strdup(line), " ");

	if(!strcmp(lineType, "v")) 
	{
		parseVertex(line);
	}
	else if(!strcmp(lineType, "f"))
	{
		parseFace(line);
	}

	return;
}

float* crossProduct(float *a, float *b)
{
	float Product[3];

        //Cross product formula 
	Product[0] = (a[1] * b[2]) - (a[2] * b[1]);
	Product[1] = (a[2] * b[0]) - (a[0] * b[2]);
	Product[2] = (a[0] * b[1]) - (a[1] * b[0]);

	return Product;
}

float* normalize(float *a){
	float x = a[0];
	float y = a[1];
	float z = a[2];

	float result[3];

    float length = sqrt(x*x+y*y+z*z);

    x = x/length;
    y = y/length;
    z = z/length;

	result[0] = x;
	result[1] = y;
	result[2] = z;

	return result;
}

void calcVN() {

	 int index1, index2, index3;
	 float vec1[3];
	 float vec2[3];
	 float* normal;
	for (int i = 0; i < faces.size(); i ++) 
	{
		index1 = faces[i].index1;
		index2 = faces[i].index2;
		index3 = faces[i].index3;
		vec1[0] = vertices[index2 - 1].x - vertices[index1 - 1].x;
		vec1[1] = vertices[index2 - 1].y - vertices[index1 - 1].y;
		vec1[2] = vertices[index2 - 1].z - vertices[index1 - 1].z;
		vec2[0] = vertices[index3 - 1].x - vertices[index1 - 1].x;
		vec2[1] = vertices[index3 - 1].y - vertices[index1 - 1].y;
		vec2[2] = vertices[index3 - 1].z - vertices[index1 - 1].z;

		normal = normalize(crossProduct(vec1, vec2));

		vertices[index1 - 1].vn.x += normal[0];
		vertices[index1 - 1].vn.y += normal[1];
		vertices[index1 - 1].vn.z += normal[2];
		vertices[index2 - 1].vn.x += normal[0];
		vertices[index2 - 1].vn.y += normal[1];
		vertices[index2 - 1].vn.z += normal[2];
		vertices[index3 - 1].vn.x += normal[0];
		vertices[index3 - 1].vn.y += normal[1];
		vertices[index3 - 1].vn.z += normal[2];

	}

	//normalize each vertex normal
	for(int i = 0; i < vertices.size(); i ++) 
	{
		float temp[3];
		temp[0] = vertices[i].vn.x;
		temp[1] = vertices[i].vn.y;
		temp[2] = vertices[i].vn.z;

		float* a;
		a = normalize(temp);
		temp[0] = a[0];
		temp[1] = a[1];
		temp[2] = a[2];
	}

	return;
}

int readFile(char *filename) {
	std::fstream objFile;
	objFile.open(filename);

	if(objFile.is_open())
	{
		char line[255];

		//parse object file line by line
		while(objFile.good())
		{
			objFile.getline(line, 255);
			parseLine(line);
		}

		objFile.close();
	}
	else
	{
		
		return -1;
	}

	calcVN();
	calcText();
	return 0;
}


void draw() {
	glColor3f(1.0,.0,.0);

	glBegin(GL_TRIANGLES);

	for (int i = 0; i < faces.size(); i ++) 
	{
		
		glNormal3f(vertices[faces[i].index1 - 1].vn.x, vertices[faces[i].index1 - 1].vn.y, vertices[faces[i].index1 - 1].vn.z);
		glTexCoord2d(vertices[faces[i].index1 - 1].text.s, vertices[faces[i].index1 - 1].text.t);
		glVertex3f(vertices[faces[i].index1 - 1].x, vertices[faces[i].index1 - 1].y, vertices[faces[i].index1 - 1].z);

		glNormal3f(vertices[faces[i].index2 - 1].vn.x, vertices[faces[i].index2 - 1].vn.y, vertices[faces[i].index2 - 1].vn.z);
		glTexCoord2d(vertices[faces[i].index2 - 1].text.s, vertices[faces[i].index2 - 1].text.t);
		glVertex3f(vertices[faces[i].index2 - 1].x, vertices[faces[i].index2 - 1].y, vertices[faces[i].index2 - 1].z);
	
		glNormal3f(vertices[faces[i].index3 - 1].vn.x, vertices[faces[i].index3 - 1].vn.y, vertices[faces[i].index3 - 1].vn.z);
		glTexCoord2d(vertices[faces[i].index3 - 1].text.s, vertices[faces[i].index3 - 1].text.t);
		glVertex3f(vertices[faces[i].index3 - 1].x, vertices[faces[i].index3 - 1].y, vertices[faces[i].index3 - 1].z);
	}

	glEnd();
}

void display(void)
{
	// put your OpenGL display commands here
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

	// reset OpenGL transformation matrix
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity(); // reset transformation matrix to identity

	
	gluLookAt(0.f,3.f,6.f,0.f,0.f,0.f,0.f,1.f,0.f);
	glRotatef(fRotateAngle,0.f,1.f,0.f);
	glShadeModel(GL_SMOOTH);
	
	//material definition
	GLfloat amb[] = {.1,0.1,0.1,1.0};
	GLfloat diff[] = {1.0, 1.0, 1.0, 1.0};
	glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, amb);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, diff);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, diff);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 110.0);
	
	if(textOn == 0)
	{
	glBindTexture(GL_TEXTURE_2D, texture[0]);
	}
	if(textOn == 1)
	{
		
	glBindTexture(GL_TEXTURE_2D, texture[1]);
	}
	glEnable(GL_TEXTURE_2D);
	/*
	if(textOn)
	{
		//printf("texture on\n");
		glBindTexture(GL_TEXTURE_2D, texture[0]);
	}
	else 
	{
		printf("texture off\n");
		glBindTexture(GL_TEXTURE_2D, texture[1]);
	}
	*/
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_NEAREST); 
 
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
 
 
	//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL); 
 
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); 
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT); 
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	draw();

	
	
	//glFlush();
	glutSwapBuffers();	// swap front/back framebuffer to avoid flickering 
	glDisable(GL_TEXTURE_2D);
	curClock=clock();
	float elapsed=(curClock-startClock)/(float)CLOCKS_PER_SEC;
	if(elapsed>1.0f){
		float fps=(float)(curF-prevF)/elapsed;
		//printf("fps:%f\n",fps);
		prevF=curF;
		startClock=curClock;
	}
}
 
void reshape (int w, int h)
{
	// reset viewport ( drawing screen ) size
	glViewport(0, 0, w, h);
	float fAspect = ((float)w)/h; 
	// reset OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(70.f,fAspect,0.001f,30.f); 
}



void keyboard(unsigned char key, int x, int y)
{
	// put your keyboard control here
	if (key == 27) 
	{
		// ESC hit, so quit
		printf("demonstration finished.\n");
		exit(0);
	}
	else if (key == 't')
	{
		textOn = 1 - textOn;
		if(textOn == 1) printf("textOn is true\n");
		//printf("Texture mode change\n");
	}
	
	
}

void mouse(int button, int state, int x, int y)
{
	// process your mouse control here
	if (button == GLUT_LEFT_BUTTON && state == GLUT_DOWN)
		printf("push left mouse button at point (%d, %d).\n", x, y);
}


void timer(int v)
{
	fRotateAngle += 1.f; // change rotation angles
	glutPostRedisplay(); // trigger display function by sending redraw into message queue
	glutTimerFunc(1000/nFPS,timer,v); // restart timer again
}


int main(int argc, char* argv[])
{
	readFile("teapot_0.obj.txt");
	//srand((unsigned int) (time(0)));
	glutInit(&argc, (char**)argv);
	// set up for double-buffering & RGB color buffer & depth test
	glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH); 
	glutInitWindowSize (800, 800); 
	glutInitWindowPosition (100, 100);
	glutCreateWindow ((const char*)"MP3 Teaport");

	init(); // setting up user data & OpenGL environment
	
	// set up the call-back functions 
	glutDisplayFunc(display);  // called when drawing 
	glutReshapeFunc(reshape);  // called when change window size
	glutKeyboardFunc(keyboard); // called when received keyboard interaction
	glutMouseFunc(mouse);	    // called when received mouse interaction
	glutTimerFunc(100,timer,nFPS); // a periodic timer. Usually used for updating animation
	
	startClock=clock();

	glutMainLoop(); // start the main message-callback loop

	return 0;
}
