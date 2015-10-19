//  
// MP1 Dancing "I" for CS418
// HUANG Tianwei, Netid: thuang23
//
#include "StdAfx.h"
#include <stdio.h>
#include <stdlib.h>
#include <GL/glut.h>
#include <ctime>
#include <cmath>

//#include <SOIL/SOIL.h>

#define PI 3.1415926


int nFPS = 40;
float fRotateAngle = 0.f;
clock_t startClock=0,curClock;
long long int prevF=0,curF=0;
int dipMode=1;



void init(void)
{
	// init your data, setup OpenGL environment here
	glClearColor(0.9,0.9,0.9,1.0); // clear color is gray		
	glPolygonMode(GL_FRONT_AND_BACK, GL_LINE); // uncomment this function if you only want to draw wireframe model
					// GL_POINT / GL_LINE / GL_FILL (default)
	glPointSize(4.0);
}

float random(float x) {
	return  (( (float) rand() / (float)(RAND_MAX/x) ) - x / 2.0);
}

float sine(float times) {
	return sin(times * fRotateAngle * PI / 180.0) * 0.2;
}
void display(void)
{
	
	if(dipMode==1)
	{
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	}else{
		glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	}
	
	
	curF++;
	// put your OpenGL display commands here
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

	// reset OpenGL transformation matrix
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity(); // reset transformation matrix to identity

	// setup look at transformation so that 
	// eye is at : (0,0,3)
	// look at center is at : (0,0,0)
	// up direction is +y axis
	gluLookAt(0.f,0.f,3.f,0.f,0.f,0.f,0.f,1.f,0.f);
	//glRotatef(fRotateAngle,0.f,1.f,0.f);

	// Test drawing a solid teapot
	glColor3f(1.0,.0,.0);
	//glutSolidTeapot(1.f); // call glut utility to draw a solid teapot 
	
	//Use strip/fan and 15 vertex call to make the letter I
	//9 calls in FAN and 6 calls in STRIP
	glShadeModel(GL_SMOOTH);
	glBegin(GL_TRIANGLE_FAN );

	glVertex2f(-1. + sine(1.),1.6 + sine(1.));//1
	glVertex2f(-1.6 + sine(1.),1.6 + sine(1.));//2
	glColor3f(1.,165./255.,0);//orange
	glVertex2f(-1.6 + sine(2.),1.2 + sine(2.));//3
	glColor3f(1.,1.,0.);//yellow
	glVertex2f(-1.2 + sine(3.),1.2 + sine(2.));//4
	glColor3f(152./255.,251./255.,152./255.);//pale green
	glVertex2f(-1.2 + sine(2.),.8 + sine(1.));//5
	glColor3f(50./255.,205./255.,50./255.);//green
	glVertex2f(-.8 + sine(3.),.8 + sine(3.));//6
	glColor3f(154./255.,205./255.,50./255.);//yellow green
	glVertex2f(-.8 + sine(4.),1.2 + sine(4.));//7
	glColor3f(0./255.,191./255.,255./255.);//sky blue
	glVertex2f(-.4 + sine(3.),1.2 + sine(4.));//8
	glColor3f(160./255.,32./255.,240./255.);//purple
	glVertex2f(-.4 + sine(1.),1.6 + sine(1.));//9
    glEnd();

	glBegin(GL_TRIANGLE_STRIP );
	glColor3f(160./255.,32./255.,240./255.);//purple
	glVertex2f(-.4 + sine(2.),.8 + sine(4.));//10
	glColor3f(0./255.,191./255.,255./255.);//sky blue
	glVertex2f(-.4 + sine(3.),.4 + sine(2.));//11
	glColor3f(50./255.,205./255.,50./255.);//green
	glVertex2f(-.8 + sine(3.),.8 + sine(3.));//6
	glColor3f(152./255.,251./255.,152./255.);//pale green
	glVertex2f(-1.6 + sine(2.),.4 + sine(5.));//12
	glColor3f(1.,1.,0.);//yellow
	glVertex2f(-1.2 + sine(2.),.8 + sine(1.));//5
	glColor3f(1.,0.,0);
	glVertex2f(-1.6 + sine(4.),.8 + sine(6.));//13


	glEnd();


	glColor3f(1.,0.65,0.);
	//draw another "I"
	glBegin(GL_LINE_LOOP );
	// the random part is a random number between -0.1 to 0.1
	//+ ( (float) rand() / (float)(RAND_MAX/0.2) ) - 0.1;
	glVertex2f(.4 + random(.1),-.4 + random(.1));
	glVertex2f(.4 + random(.1),-.8 + random(.1));
	glVertex2f(.8 + random(.1),-.8 + random(.1));
	glVertex2f(.8 + random(.1),-1.2 + random(.1));
	glVertex2f(.4 + random(.1),-1.2 + random(.1));
	glVertex2f(.4 + random(.1),-1.6 + random(.1));
	glVertex2f(1.6 + random(.1),-1.6 + random(.1));
	glVertex2f(1.6 + random(.1),-1.2 + random(.1));
	glVertex2f(1.2 + random(.1),-1.2 + random(.1));
	glVertex2f(1.2 + random(.1),-.8 + random(.1));
	glVertex2f(1.6 + random(.1),-.8 + random(.1));
	glVertex2f(1.6 + random(.1),-.4 + random(.1));
	

	glEnd();
	
	
	//glFlush();
	glutSwapBuffers();	// swap front/back framebuffer to avoid flickering 

	curClock=clock();
	float elapsed=(curClock-startClock)/(float)CLOCKS_PER_SEC;
	if(elapsed>1.0f){
		float fps=(float)(curF-prevF)/elapsed;
		printf("fps:%f\n",fps);
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
	
	if( key == 'h'){
		dipMode = 1-dipMode;
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

	srand((unsigned int) (time(0)));
	glutInit(&argc, (char**)argv);
	// set up for double-buffering & RGB color buffer & depth test
	glutInitDisplayMode (GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH); 
	glutInitWindowSize (500, 500); 
	glutInitWindowPosition (100, 100);
	glutCreateWindow ((const char*)"MP1 Dancing I");

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
