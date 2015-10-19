// assign3.cpp : Defines the entry point for the console application.
// No marks will be given if we can't compile your file
// No marks will be given if the SQL statement is fundementally incorrect and no partial credits will be given
// No marks will be given for a TODO task if it fails to get the same result from the check case in the assignment description
// If you want to appeal the score,  please run the suggested solution and compare the result
// you can print the retrieved results using printRecordIntoCol(HSTMT stmt) and printIntoRow(HSTMT stmt, int maxColumnWidth);
#include "stdafx.h"
#include <windows.h>
#include <sql.h>
#include <sqlext.h>
#include <sqltypes.h>
#include <iostream>
#include <conio.h>
#include <iomanip>
using namespace std;


HENV   henv;
HDBC   hdbc;
HSTMT  hstmt;
RETCODE	ret;

SQLINTEGER staff_id,cbStaffId; // global variables
boolean ISmanager=false; // indicate whether a user is a manager/supervise
int loginOption;
int command = 0;

boolean ConnectDB();
void DisconnectDB();
boolean userLogin();
boolean checkStaff(); //check to see if the user is really the claimed staff type
boolean checkManager(); // check to see if the user is a manager/supervisor
void mt_menu();// the menu for maintenance staffs
void showPersonal(); // showing personal information
void showAssigedWorkPlace();//show the work place assigned
void showTeam();// show the personal information of all the staff under staff_id's management (where staff_id is a manager/supervisor)
void td_menu();// the menu for train drivers
void showRouteServed();// show the route served by a train
void st_menu(); // the menu for station staffs
void showRoute();// show the routes from a station
void showSchedule();//show schedule of departure from a station
void constantQuery(int queryNo);//execute a constant query
void printRecordIntoCol(HSTMT stmt);
SQLCHAR*** printIntoRow(HSTMT stmt, int maxColumnWidth);
void changePassword();

int main(){
	// set the width and line displayed in the command prompt
	system("mode con cols=80 lines=50");

	if (ConnectDB()) {
		while(userLogin()){
			do {
				system ("CLS"); // clear the screen


				switch (loginOption){
					case 1:
						mt_menu(); //maintanence staff/manager
						break;
					case 2:
						td_menu(); // train driver/manager
						break;
					case 3:
					    st_menu(); // station staff/manager
						break;
					default: break;
				}
			} while ( command != 0);
		}
	}else {
		cout << "Oracle Connection unsuccessful.\n";
		system("pause");
	}
	DisconnectDB();
}


void st_menu(){

	int ISdone=0;

	while (!ISdone){
		cout << "===========Information System for Station staffs==============\n\n";
		cout << "0. Logout from your account                        (input '0').\n";
		cout << "1. Show your personal information                  (input '1').\n";
		cout << "2. Show your assigned station                      (input '2').\n";
		cout << "3. change your Logon password                      (input '3').\n";
		if (ISmanager){
			cout << "4. Show the names of station staffs managed by you (input '4').\n";
			cout << "5. Show the routes information                     (input '5').\n";
			cout << "6. Show the departure time from the station        (input '6').\n";
			cout << "7. Show the trains departing at each station       (input '7').\n"<< endl;
		}
		cout << "Please enter your choice: ";

		cin >> command ;

		char buf[2];
		cin.getline(buf, 2); // grab the endline character when the user press "Enter"

		cout<<endl;

		switch (command){
			case 1:
				showPersonal();
				ISdone=0;
				system("CLS");
				break;
				
			case 2:
				showAssigedWorkPlace();
				ISdone=0;
				system("CLS");
				break;
			case 3:
				changePassword();
				ISdone=0;
				system("CLS");
				break;
			case 4:
				if(!ISmanager){
					cout<<"You are not a manager, please choose again\n";
					ISdone=0;
					system("pause");
					system("CLS");
					break;
				}
				else{
					showTeam();
					ISdone=0;
					system("CLS");
					break;
				}
			case 5:
				if(!ISmanager){
					cout<<"You are not a manager, please choose again\n";
					ISdone=0;
					system("pause");
					system("CLS");
					break;
				}
				else{
					showRoute();
					ISdone=0;
					system("CLS");
					break;
				}

			case 6:
				if(!ISmanager){
					cout<<"You are not a manager, please choose again\n";
					ISdone=0;
					system("pause");
					system("CLS");
					break;
				}
				else{
					showSchedule();
					ISdone=0;
					system("CLS");
					break;
				}
			case 7:
				if(!ISmanager){
					cout<<"You are not a manager, please choose again\n";
					ISdone=0;
					system("pause");
					system("CLS");
					break;
				}
				else{
					constantQuery(3);
					ISdone=0;
					system("CLS");
					break;
				}
			case 0:
				ISdone=1;
				system ("CLS"); // Clear the screen
				break;
			default: 
				system ("CLS"); // Clear the screen
				break;
		}
	}
}

void td_menu(){

	int ISdone=0;

	while (!ISdone){
		cout << "=============Information System for Train drivers===============\n\n";
		cout << "0. Logout from your account                         (input '0').\n";
		cout << "1. Show your personal information                   (input '1').\n";
		cout << "2. Show your assigned trains                        (input '2').\n";
		cout << "3. change your Logon password                       (input '3').\n";
		if (ISmanager){
			cout << "4. Show the names of drivers managed by you         (input '4').\n";
			cout << "5. Show the route served by a train                 (input '5').\n";
			cout << "6. Show the complete manufacturer-train information (input '6').\n"<< endl;
			
		}
		cout << "Please enter your choice: ";

		cin >> command ;

		char buf[2];
		cin.getline(buf, 2); // grab the endline character when the user press "Enter"

		cout<<endl;

		switch (command){
			case 1:
				showPersonal();
				ISdone=0;
				system("CLS");
				break;
				
			case 2:
				showAssigedWorkPlace();
				ISdone=0;
				system("CLS");
				break;
			case 3:
				changePassword();
				ISdone=0;
				system("CLS");
				break;
			case 4:
				if(!ISmanager){
					cout<<"You are not a manager, please choose again\n";
					ISdone=0;
					system("pause");
					system("CLS");
					break;
				}
				else{
					showTeam();
					ISdone=0;
					system("CLS");
					break;
				}

			case 5:
				if(!ISmanager){
					cout<<"You are not a manager, please choose again\n";
					ISdone=0;
					system("pause");
					system("CLS");
					break;
				}
				else{
					showRouteServed();
					ISdone=0;
					system("CLS");
					break;
				}
			case 6:
				if(!ISmanager){
					cout<<"You are not a manager, please choose again\n";
					ISdone=0;
					system("pause");
					system("CLS");
					break;
				}
				else{
					constantQuery(2);
					ISdone=0;
					system("CLS");
					break;
				}
			case 0:
				ISdone=1;
				system ("CLS"); // Clear the screen
				break;
			default: 
				system ("CLS"); // Clear the screen
				break;
		}
	}
}

void mt_menu(){

	int ISdone=0;

	while (!ISdone){
		cout << "==============Information System for Maintenance Staffs===============\n\n";
		cout << "0. Logout from your account                               (input '0').\n";
		cout << "1. Show your personal information                         (input '1').\n";
		cout << "2. Show your assigned maintenance centers                 (input '2').\n";
		cout << "3. change your Logon password                             (input '3').\n";
		if (ISmanager){
		cout << "4. Show the names of your maintenance team                (input '4').\n";
			cout << "5. Show the remaining capacity of the maintenance centers (input '5').\n" << endl ;
		}
		cout << "Please enter your choice: ";

		cin >> command ;

		char buf[2];
		cin.getline(buf, 2); // grab the endline character when the user press "Enter"

		cout<<endl;

		switch (command){
			case 1:
				showPersonal();
				ISdone=0;
				system("CLS");
				break;
				
			case 2:
				showAssigedWorkPlace();
				ISdone=0;
				system("CLS");
				break;
			case 3:
				changePassword();
				ISdone=0;
				system("CLS");
				break;
			case 4:
				if(!ISmanager){
					cout<<"You are not a manager, please choose again\n";
					ISdone=0;
					system("pause");
					system("CLS");
					break;
				}
				else{
					showTeam();
					ISdone=0;
					system("CLS");
					break;
				}
			case 5:
				if(!ISmanager){
					cout<<"You are not a manager, please choose again\n";
					ISdone=0;
					system("pause");
					system("CLS");
					break;
				}
				else{
					constantQuery(1);
					ISdone=0;
					system("CLS");
					break;
				}
			case 0:
				ISdone=1;
				system ("CLS"); // Clear the screen
				break;
			default: 
				system ("CLS"); // Clear the screen
				break;
		}
	}
}

boolean userLogin(){

	char username[20], password[10];
	char query[1000];
	char inputUsername[20];	
	string inputPassword;
	SQLINTEGER cbUsername, cbPassword;


	boolean success= false;

	while (!success){
		cout << "====Welcome to the 3311Transit Information system===\n\n";
		cout << "Please choose one of the follow options to log in:\n";
		cout << "0. to terminate the program              (input '0').\n";
		cout << "1. Log in as a Maintenance staff/manager (input '1').\n";
		cout << "2. Log in as a Train driver/manager      (input '2').\n";
		cout << "3. Log in as a Station staff/manager     (input '3').\n\n";
		cout << "Please enter your choice: ";
		cin >> loginOption;
		
		char buf[2];
		cin.getline(buf, 2); // grab the endline character when the user press "Enter"

		// Exit if the user keys in "0"
		if (loginOption == 0) 
			break;

		cout << "Please enter your username: ";
		cin >> inputUsername;

		// Exit if the user keys in "0"
		//if (strcmp(inputUsername,"0") == 0) 
		//	break;

		cout << "Please enter your Password: ";		
		inputPassword="";

		// Get the input character by character and mask the password
		boolean flag=true;
		while(flag)
		{
           char chr=getch(); 
           if (chr=='\r') flag=false;

               else{putch('*'); inputPassword += chr;}
		}		
		
		cout << endl;

		// This part has been Done for you. 
		// Check whether the user is a valid user. This is done through checking inputUsername and password and see whether 
		// they match with staff.user_name and staff.password. The user_name and password are new added attributes, please 
        // refer to the 'insert_record.sql' for the exact values. Note that we are using SQLExecDirectA(), and we copy the 
		// returned values from the Oracle server using the SQLBindCol() function. We then SQLFetch() to retrieve the results 
		//(the columns: user_name,password,staff_id) from Oralce and copy them to the local variables username,password, 
		//staff_id.
		
		SQLAllocStmt(hdbc, &hstmt);
		sprintf(query,"select user_name, password, staff_id from staff where user_name=\'%s\'",inputUsername);
		SQLExecDirectA(hstmt, (SQLCHAR *)query, SQL_NTS);
		SQLBindCol(hstmt,1,SQL_C_CHAR,username,20,&cbUsername);
		SQLBindCol(hstmt,2,SQL_C_CHAR,password,10,&cbPassword);
		SQLBindCol(hstmt,3,SQL_INTEGER,&staff_id,10,&cbStaffId);
		ret = SQLFetch(hstmt);

		if (ret==SQL_SUCCESS || ret ==SQL_SUCCESS_WITH_INFO) {
			if (strcmp(inputPassword.c_str(),password) != 0) {
				cout << "Password Incorrect, please try again.\n";
				success = false;
				system("pause");
				system("CLS");
				
			} else{				
				success = true;
			}
		} else {
			cout << "User does not exist, please try again.\n";
			success = false;
			system("pause");
			system("CLS");
			
		}
		SQLFreeStmt(hstmt,SQL_CLOSE);
		

        
		boolean staffTypeCorrect=false;
		staffTypeCorrect=checkStaff(); //check to see if the claimed staff type is correct
		if (success){
			if (staffTypeCorrect){
				// Check to see the staff is a manager, checkManager will update the global variable ISmanager accordingly
				checkManager();
				system ("CLS"); // Clear the screen
				success = true;

			}
			else { //staff exist in the main staff table, but he is not of the claimed staff type
				cout << "Your staff type is incorrect, please try again.\n";
				success = false;
				system("pause");
				system("CLS");

			}
		}

		cout<<endl;	
	}

	return success;
}


boolean checkStaff()
{
    boolean staffCorrect=false;
	char tableName[100];// the name of the SQL table to check
    SQLINTEGER noOfRecord=0;
	SQLINTEGER cbNoOfRecord;
	char query[1000];


	switch (loginOption){
			case 1: strcpy(tableName,"maintenance_staff");//claims to be a maintanence staff/manager
					break;
			case 2: strcpy(tableName,"train_driver");//claims to be a train driver/manager
					break;
			case 3: strcpy(tableName,"station_staff");//claims to be station staff/manager
					break;
			default: break;
	}


	// Check to see if the staff is really of the staff type he/she claims himself/herself to be
	SQLAllocStmt(hdbc, &hstmt);
	sprintf(query,"select count(*) from %s where staff_id=%d",tableName,staff_id);
	SQLExecDirectA(hstmt, (SQLCHAR *)query, SQL_NTS);
	SQLBindCol(hstmt,1,SQL_INTEGER,&noOfRecord,1,&cbNoOfRecord);//assume always successful so no error checking here
	SQLFetch(hstmt);//assume always successful so no error checking here
	SQLFreeStmt(hstmt,SQL_CLOSE);

	if (noOfRecord>0){
		staffCorrect=true;
	}
	else{
		staffCorrect=false;
	}

	return staffCorrect;

}


boolean checkManager(){
	char tableName[100];// the name of the SQL table to check
    SQLINTEGER noOfRecord=0;
	SQLINTEGER cbNoOfRecord;
	char query[1000];

    ISmanager=false;

	switch (loginOption){
			case 1: strcpy(tableName,"maintenance_supervise");//check to see if he is a maintanence manager
					break;
			case 2: strcpy(tableName,"train_manage");//check to see if he is a train manager
					break;
			case 3: strcpy(tableName,"station_manage");//check to see if he is a station manager
					break;
			default: break;
	}


	// check to see if the staff is a manager
	SQLAllocStmt(hdbc, &hstmt);
	sprintf(query,"select count(*) from %s where manager_id=%d",tableName,staff_id);
	SQLExecDirectA(hstmt, (SQLCHAR *)query, SQL_NTS);
	SQLBindCol(hstmt,1,SQL_INTEGER,&noOfRecord,1,&cbNoOfRecord);//assume always successful so no error checking here
	SQLFetch(hstmt);//assume always successful so no error checking here
	SQLFreeStmt(hstmt,SQL_CLOSE);

	if (noOfRecord>0){
		ISmanager=true;
	}
	else{
		ISmanager=false;
	}
	return ISmanager;
}



void changePassword(){
	char newPassword[10];
	char query[1000];

	cout<< "\nPlease input your new password: (at most 10 characters):";
	cin >> newPassword;
	// TODO 1: Update the database for staff.password.
	// for the expect behavior of this part please refer to the executable program
	// Add your code here

	SQLAllocStmt(hdbc, &hstmt);
	sprintf(query, "update staff set password=\'%s\' where staff_id=%d", newPassword, staff_id);
	SQLExecDirectA(hstmt, (SQLCHAR *)query, SQL_NTS);

	system("pause");
}


void showPersonal(){
	SQLAllocStmt(hdbc, &hstmt);
	char query[1000];

	char last_name[100];
	char first_name[100];
	char gender[1];
	char address[100];


	SQLINTEGER cbLastname;
	SQLINTEGER cbFirstname;
	SQLINTEGER cbGender;
	SQLINTEGER cbAddress;


	cout<<"Here is your personal information:\n";
	cout<<"----------------------------------\n";

	// TODO 2: Show the personal information of a staff according to his staff_id value (global variable)
	sprintf(query,"select last_name, first_name, address, gender from staff where staff_id=%d",staff_id);
	SQLExecDirectA(hstmt, (SQLCHAR *)query, SQL_NTS);
	SQLBindCol(hstmt,1,SQL_CHAR,last_name,100,&cbLastname);
	SQLBindCol(hstmt,2,SQL_CHAR,first_name,100,&cbFirstname);
	SQLBindCol(hstmt,3,SQL_CHAR,address,100,&cbAddress);
	SQLBindCol(hstmt,4,SQL_CHAR,gender,1,&cbGender);

	SQLFetch(hstmt);
	SQLFreeStmt(hstmt,SQL_CLOSE);
	cout << gender << endl;
	system("pause");
}


void showSchedule(){
	SQLAllocStmt(hdbc, &hstmt);
	char query[1000];
    char stationName[100];

	cout<< "\nPlease input the train station Name:";
	cin >> stationName;

	cout<<endl;
	cout<<"Here are the route information:\n";
	cout<<"--------------------------------------\n";

	char departure[100];

	SQLINTEGER cbDeparture;

	// TODO 3: retrieve the route number and the departure time for the routes departing from the station (stationName) 

	sprintf(query, "select R.route_n, S.departure_time from route R, schedule S where R.route_n=S.route_n and R.s_station=\'%s\'", stationName);
	SQLExecDirectA(hstmt, (SQLCHAR *)query, SQL_NTS);
	SQLBindCol(hstmt,2,SQL_CHAR,departure,100,&cbDeparture);

	printIntoRow(hstmt,25);

	SQLFreeStmt(hstmt,SQL_CLOSE);

	system("pause");
}

void showRouteServed(){
	SQLAllocStmt(hdbc, &hstmt);
	char query[1000];
    SQLINTEGER trainID;

	char s_station[100];

	SQLINTEGER cbSStation;

	cout<< "\nPlease input the train ID:";
	cin >> trainID;

	cout<<endl;
	cout<<"Here is the service information:\n";
	cout<<"----------------------------------\n";

	// TODO 4: retrieve the start_station, end_station being served by a train with train_id=trainID 
	
	sprintf(query,"select R.s_station, R.e_station from route R, train T where R.route_n=T.route_n and T.train_id=%d",trainID);
	SQLExecDirectA(hstmt, (SQLCHAR *)query, SQL_NTS);
	SQLBindCol(hstmt,1,SQL_CHAR,s_station,100,&cbSStation);

	SQLFetch(hstmt);
	SQLFreeStmt(hstmt,SQL_CLOSE);

	cout << s_station << endl;
	system("pause");
}

void showRoute(){
	SQLAllocStmt(hdbc, &hstmt);
	char query[1000];
    char stationName[100];
    SQLINTEGER routeNo;

	cout<< "\nPlease input the route number:";
	cin >> routeNo;

	cout<<endl;
	cout<<"Here is the route information:\n";
	cout<<"--------------------------------------------------\n";

	// TODO 5: retrieve the start_station,end_station of a route
	sprintf(query, "select s_station, e_station from route where route_n=%d", routeNo);

}


void showAssigedWorkPlace(){
	SQLAllocStmt(hdbc, &hstmt);
	char query[1000];
	//tableName1 holds name of the table holding the information for "works in","drive", "assgined to"
	//tableName2 holds name of the table that indicates the exact work-place
	//attributes contains the attributes to be retrieved for each case
	//output is for output the correct header information
	char tableName1[100],tableName2[100],attributes[100],output[100]; 
	
	switch (loginOption){
			case 1: strcpy(tableName1,"work_in_mcenter");//use the work_in_mcenter table 
                    strcpy(tableName2,"maintenance_center");		
					strcpy(attributes,"name");
					strcpy(output,"Maintenance Centers");
					break;
			case 2: strcpy(tableName1,"drive");//use the drive table
				    strcpy(tableName2,"train");
					strcpy(attributes,"train_id");
					strcpy(output,"Train ID of the train");
					break;
			case 3: strcpy(tableName1,"station_staff");////use the station_manage table
				    strcpy(tableName2,"station_staff");
					strcpy(attributes,"name");
					strcpy(output,"Station");
					break;
			default: break;
	}

	char result[100];
	SQLINTEGER cbResult;
	

	cout<<"Here are the "<< output <<" you have been assigned:\n";
	cout<<"------------------------------------------------------------\n";

	// TODO 6: Retrieve the work place information for 1.maintenance staff, 2.train driver, 3.station staff 
	// the information are in the relationships "works in", "drive", "assigned to" (and the subsequent tables converted from them)
	// you just need a single SQL statment, and supplied it properly with the variables tableName1[100],tableName2[100],attributes[100]
	// Add your code here		
	
	sprintf(query, "select A2.%s from %s A2, %s A1 where A2.%s=A1.%s and A1.staff_id=%d", 
		attributes, tableName2, tableName1, attributes, attributes, staff_id);
	SQLExecDirectA(hstmt, (SQLCHAR *)query, SQL_NTS);
	SQLBindCol(hstmt,1,SQL_CHAR,result,100,&cbResult);
	SQLFetch(hstmt);
	SQLFreeStmt(hstmt,SQL_CLOSE);

	cout << result << endl;
	system("pause");
}

void showTeam(){
	SQLAllocStmt(hdbc, &hstmt);
	char query[1000];
	char tableName[100]; 
	
	switch (loginOption){
			case 1: strcpy(tableName,"maintenance_supervise");//use the maintenance_supervise table 
				                                              //(join to find all the staffs under management of staff_id)
					break;
			case 2: strcpy(tableName,"train_manage");//use the train_manage table
					break;
			case 3: strcpy(tableName,"station_manage");////use the station_manage table
					break;
			default: break;
	}

	cout<<"Here are the staffs who are under your management:\n";
	
	// TODO 7:  retrieve the staffs managed by the manager with the particular staff_id value
	// only one SQL statement is needed
	// Add your code here		

	sprintf(query, "select S.last_name, S.first_name from staff S, maintenance_supervise T \
				   where S.staff_id=T.staff_id and T.manager_id=%d", staff_id);

	// the function call to printIntoRow() is provided, assume you have already executed the query with the statement handle "hstmt"
	// this part is just to print out the result of the query (full code provided already)
	printIntoRow(hstmt,25);
	SQLFreeStmt(hstmt,SQL_CLOSE);
	system("pause");

}

void constantQuery(int queryNo){

	SQLAllocStmt(hdbc, &hstmt);
	char query[1000];
	
	switch (queryNo){
			case 1: //TODO 8: Query for menu option 5 of a maintenance staff
				sprintf(query, "select MC.name, \
							   10 - count(MR.train_id) \
							   from maintain_and_repair MR, \
							   maintenance_center MC \
							   where MC.name=MR.name \
							   group by MC.name");
				break;
			case 2: //TODO 9: Query for menu option 6 of a train driver
				sprintf(query, "select M.name, \
							   LISTAGG(T.train_id, ',') within group (order by T.train_id) as \"Trains\"\
							   from train_manufacturer M, train T \
							   where M.m_id=T.m_id \
							   group by M.name");
				break;
			case 3: //TODO 10: Query for menu option 7 of a station staff
				sprintf(query, "select S.name as \"Station Name\", \
							   LISTAGG(T.train_id, ',') within group (order by T.train_id) as \"Trains\", \
							   count(T.train_id) \
							   from train T, station S, route R \
							   where S.name=R.s_station and T.route_n=R.route_n \
							   group by S.name");
				break;
			default: break;
	}

	cout<<"Here are the results:\n";

	SQLExecDirectA(hstmt, (SQLCHAR *) query,SQL_NTS);

	// the function call to printIntoRow() has been provided
	printIntoRow(hstmt,25);
	SQLFreeStmt(hstmt,SQL_CLOSE);
	system("pause");

}



boolean ConnectDB() {
	RETCODE        ret;	
	/* Allocate environment handle */
	ret = SQLAllocEnv( &henv);
	/* Allocate connection handle */
	ret = SQLAllocConnect(henv, &hdbc);
	/* Connect to the service */

	char oracleAccountName[20];
	string inputPassword;

	cout << "========3311Transit Information System DB manager logon page=========\n\n";
		
	cout << "Please enter your Oracle account username: ";
	cin >> oracleAccountName;
	cout << "Please enter your Oracle account Password: ";		
	inputPassword="";

	// Mask the password
	boolean flag=true;
	while(flag){
          char chr=getch(); 
          if (chr=='\r') flag=false;

               else{putch('*'); inputPassword += chr;}
	}		
	cout << endl;
	cout << oracleAccountName << endl;
	cout << inputPassword.c_str() << endl;
	cout << "end" << endl;
	system("pause");


	ret = SQLConnectA(hdbc, (SQLCHAR*) "comp3311.cse.ust.hk", SQL_NTS, (SQLCHAR*) oracleAccountName, SQL_NTS, (SQLCHAR*) inputPassword.c_str(), SQL_NTS);
	system ("CLS"); // clear the screen
	if (ret == SQL_SUCCESS || ret == SQL_SUCCESS_WITH_INFO)
		return TRUE;
	return FALSE;
}

void DisconnectDB() {
	SQLDisconnect(hdbc);
	SQLFreeConnect(hdbc);
	SQLFreeEnv(henv);
}

// A generic function prints each row of return value into a column of information
void printRecordIntoCol(HSTMT stmt){
   SQLCHAR columnName[10][64];
   SQLSMALLINT  noOfcolumns, columNameLength[10], dataType[10], decimalDigits[10], nullable[10];
   SQLULEN columnSize[10];
   SQLCHAR buf[10][64];
   SQLINTEGER indicator[10];

   // Find the total number of columns
   SQLNumResultCols(stmt, &noOfcolumns);
   
   for (int i = 0; i < noOfcolumns; i++) {
	  // Retreive the column metadata
	  ret = SQLDescribeColA(hstmt,i+1,columnName[i], sizeof(columnName[i]), &columNameLength[i], &dataType[i],&columnSize[i],&decimalDigits[i],&nullable[i]);
	  // Bind the column result
	  SQLBindCol( stmt, i + 1, SQL_C_CHAR, buf[ i ], sizeof(buf[i]), &indicator[ i ]);
   }

   // Print out the query result
   while (SQL_SUCCEEDED(SQLFetch(stmt))) {
	   for ( int i = 0; i < noOfcolumns; i ++ ) {
		   cout <<setw(15)<<left<< columnName[i]<<": "<< buf[i] <<endl;		   
	   }
	   //cout<<endl;
   }
}

// A generic function prints out the query result by column with a maximum column width
SQLCHAR*** printIntoRow(HSTMT stmt, int maxColumnWidth){
   SQLCHAR columnName[10][64];
   SQLSMALLINT  noOfcolumns, columNameLength[10], dataType[10], decimalDigits[10], nullable[10];
   SQLULEN columnSize[10];
   SQLCHAR buf[10][64];
   SQLCHAR*** result;
   SQLINTEGER indicator[10];

   // Find the total number of columns
   SQLNumResultCols(stmt, &noOfcolumns);
   

   for(int i=0;i<maxColumnWidth*noOfcolumns;i++)
	   cout <<"-";
   cout<<endl;

   // Initialize the result pointer
   result = new SQLCHAR**[200];
   for(int i=0;i<100;i++){
	   result[i] = new SQLCHAR*[10];
      for(int j=0;j<noOfcolumns;j++){
		 result[i][j] = new SQLCHAR[64];
	  }
   }

   for (int i = 0; i < noOfcolumns; i++) {
	  // Retreive the column metadata
	  ret = SQLDescribeColA(hstmt,i+1,columnName[i], sizeof(columnName[i]), &columNameLength[i], &dataType[i],&columnSize[i],&decimalDigits[i],&nullable[i]);

	  // Bind the column result
	  SQLBindCol( stmt, i + 1, SQL_C_CHAR, buf[ i ], sizeof(buf[i]), &indicator[ i ]);
   }

   int totalLength=0;
   // Print out the column name
   for ( int i = 0; i < noOfcolumns; i ++ ) {
		if(columnSize[i]<columNameLength[i]){
			cout <<setw(columNameLength[i]+2)<<left<< columnName[i];		
			totalLength+=columNameLength[i]+2;
		}
	    else if(columnSize[i]<maxColumnWidth){
			cout <<setw(columnSize[i]+2)<<left<< columnName[i];		
			totalLength+=columnSize[i]+2;
		}else{
			cout <<setw(maxColumnWidth)<<left<< columnName[i];		
			totalLength+=maxColumnWidth;
		}
    }
   cout<<endl;

   // Print out separate line
   for(int i=0;i<maxColumnWidth*noOfcolumns;i++)
	   cout <<"-";
   cout<<endl;

   // Print out the query result row by row
   int j=0;
   while (SQL_SUCCEEDED(SQLFetch(stmt))) {
	   for ( int i = 0; i < noOfcolumns; i ++ ) {
		    // deep copy
			for(int k=0; k<sizeof(buf[i]);k++){
				result[j][i][k] = buf[i][k];
			}
			if(columnSize[i]<columNameLength[i]){
				cout <<setw(columNameLength[i]+2)<<left<< buf[i];		
			}
			else if(columnSize[i]<maxColumnWidth){
				cout <<setw(columnSize[i]+2)<<left<< buf[i];		
			}
			else{
				cout <<setw(maxColumnWidth)<<left<< buf[i];		
			}
	   }
	   j++;
	   cout<<endl;
   }
   
   return result;
}