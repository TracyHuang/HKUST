/*
** server.c -- a stream socket server demo
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>

//#define PORT "3490"  
// the port users will be connecting to

#define BACKLOG 10	 // how many pending connections queue will hold

void sigchld_handler(int s)
{
	while(waitpid(-1, NULL, WNOHANG) > 0);
}

// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa)
{
	if (sa->sa_family == AF_INET) {
		return &(((struct sockaddr_in*)sa)->sin_addr);
	}

	return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

void cmp(char* ans, char* guess, int* correctNum, int* correctColorNum) 
{
	*correctNum = 0;
	*correctColorNum = 0;
	//match all correct guesses first
	for(int i = 0; i < 4; i ++) 
	{
		if(ans[i] == guess[i]) 
		{
			(*correctNum) ++;
		}
	}
	//get all correct colors
	for (int i = 0; i < 4; i ++)
	{
		if (ans[i] != guess[i])
		{
			for (int j = 0; j < 4; j ++)
			{
				if(ans[i] == guess[j])
				{
					(*correctColorNum) ++;
					break;
				}
			}
		}
	}
	
	return;
}

void game(int new_fd, char* ans) 
{
	bool gameOver = false;
	char guess[5];
	int correctNum, correctColorNum;
	int roundLeft = 8;
	int numbytes = 0;
	char message[2];
	messgae[1] = '\0';
	while (roundLeft > 0) {
	if ((numbytes = recv(new_fd, guess, 4, 0)) == -1) {
			perror("recv");
		}
	guess[4] = '\0';
	
	cmp(ans, guess, &correctNum, &correctColorNum);
	
	if( send(new_fd, &correctNum, sizeof(correctNum), 0) == -1)
				perror("send");
	if( send(new_fd, &correctColorNum, sizeof(correctColorNum), 0) == -1)
				perror("send");
	
	if(correctNum == 4) 
	{
		message[1] = 'e';
		if (send(new_fd, message, 1, 0) == -1)	perror("send");
		break;
	}
	else {
		message[1] = 'c';
	}
	roundLeft --;
		if(roundLeft != 0) 
		{
			if (send(new_fd, message, 1, 0) == -1)	perror("send");	
		}
		else 
		{
			message[1] = 'e';
			if (send(new_fd, message, 1, 0) == -1)	perror("send");
		}
	}
}

int main(int argc, char *argv[])
{
	// generate answer array
	char answer[5];
	printf("Please enter the color selection(\"random\" for random generated color selection):\n");
	scanf ("%4s",answer);
	if (strcmp(answer, "rand") == 0) {
		while (int i = 0; i < 4; i ++) {
			int temp = rand() % 6;
			char str = (char)(((int)'0')+temp);
			answer[i] = str;
		}
	}
	answer[4] = '\0';
	


	int sockfd, new_fd;  // listen on sock_fd, new connection on new_fd
	struct addrinfo hints, *servinfo, *p;
	struct sockaddr_storage their_addr; // connector's address information
	socklen_t sin_size;
	struct sigaction sa;
	int yes=1;
	char s[INET6_ADDRSTRLEN];
	int rv;

	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = AI_PASSIVE; // use my IP

	if ((rv = getaddrinfo(NULL, argv[1], &hints, &servinfo)) != 0) {           //port is set to be argv[1] as it is now user's right to choose the port
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
		return 1;
	}

	// loop through all the results and bind to the first we can
	for(p = servinfo; p != NULL; p = p->ai_next) {
		if ((sockfd = socket(p->ai_family, p->ai_socktype,
				p->ai_protocol)) == -1) {
			perror("server: socket");
			continue;
		}

		if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes,
				sizeof(int)) == -1) {
			perror("setsockopt");
			exit(1);
		}

		if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
			close(sockfd);
			perror("server: bind");
			continue;
		}

		break;
	}

	if (p == NULL)  {
		fprintf(stderr, "server: failed to bind\n");
		return 2;
	}

	freeaddrinfo(servinfo); // all done with this structure

	if (listen(sockfd, BACKLOG) == -1) {
		perror("listen");
		exit(1);
	}

	sa.sa_handler = sigchld_handler; // reap all dead processes
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = SA_RESTART;
	if (sigaction(SIGCHLD, &sa, NULL) == -1) {
		perror("sigaction");
		exit(1);
	}

	printf("server: waiting for connections...\n");

	while(1) {  // main accept() loop
		sin_size = sizeof their_addr;
		new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size);
		if (new_fd == -1) {
			perror("accept");
			continue;
		}

		inet_ntop(their_addr.ss_family,
			get_in_addr((struct sockaddr *)&their_addr),
			s, sizeof s);
		printf("server: got connection from %s\n", s);

		if (!fork()) { // this is the child process
			close(sockfd); // child doesn't need the listener
			/* MP0
			FILE *f = fopen(argv[1], "rb");
			fseek(f, 0, SEEK_END);
			int fsize = ftell(f);
			fseek(f, 0, SEEK_SET);

			char *string = malloc(fsize + 1);
			fread(string, fsize, 1, f);
			fclose(f);
			
			string[fsize] = 0;
			
			if( send(new_fd, &fsize, sizeof(fsize), 0) == -1)
				perror("send");
			
			if (send(new_fd, string, fsize, 0) == -1)
				perror("send");
			*/
			game(new_fd, answer);
			close(new_fd);
			exit(0);
		}
		close(new_fd);  // parent doesn't need this
	}

	return 0;
}

