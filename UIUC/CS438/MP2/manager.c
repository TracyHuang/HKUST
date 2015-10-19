/*
** CS438 SP14 MP2
** Huang Tianwei
** thuang23
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <stdbool.h>


#define MYPORT "4950"	// the port users will be connecting to
#define MAXMESSAGELENGTH 100
#define MAXBUFLEN 100
#define MAXNUMMESSAGE 100

struct adjacent_node{
	int id;
	struct sockaddr_storage router_addr;
	int cost;
	bool online;
};

struct message{
	int from;
	int to;
	char message[MAXMESSAGELENGTH];
        int  path[16];
  int path_counter;
};

struct top_edge{
	int from;
	int to;
	int cost;
};

int topology[16][16];
bool exist[16];
bool online[16];
int numNode = 0;
struct sockaddr_storage* router_addr; 

struct message mes[MAXNUMMESSAGE];
int numMessage = 0;

void sendMessages(int sockfd) {
  printf("start sending messages\n");
        int numbytes;
	for (int i = 0; i < numMessage ; i ++) {
		if (numbytes = sendto(sockfd, mes + i, sizeof(mes[i]), 0,
				      (struct sockaddr*)    &( router_addr[mes[i].from - 1]), sizeof(router_addr[mes[i].from - 1])) == -1) {
			perror("sendto");
			exit(1);
		}	
	}

	char buf[100];
	struct sockaddr_storage their_addr;
	socklen_t socklen = sizeof(their_addr);
	for (int i = 0; i < numNode; i ++) {
	  if (numbytes = recvfrom(sockfd, buf, 100, 0, (struct sockaddr*) &their_addr, &socklen) == -1) { 
	    printf("error");
	    exit(1);
	  }
	}

	  printf("end sending messages\n");
}

void update(int sockfd) {
	int from, to, cost, numbytes;
	struct top_edge new_edge;
	while (scanf("%d %d %d", &from, &to, &cost)) {
	  printf("new topology edge: from %d to %d with a distance of %d", from, to, cost);
	        topology[from-1][to-1] = cost;
			topology[to-1][from-1] = cost;
			new_edge.from = from;
			new_edge.cost = cost;
			new_edge.to = to;
			for (int i = 0; i < 16; i ++) {
				if (numbytes = sendto(sockfd, &new_edge, sizeof(new_edge), 0,
						      (struct sockaddr *)     &(router_addr[i]), sizeof(router_addr[i])) == -1) {
				perror("sendto");
				exit(1);
				}	
			}
		sendMessages(sockfd);
	}
}

int leastID() {
	for (int i = 0; i < 16; i ++) {
	  if (exist[i] && (!online[i])) {
			online[i] = true;
			return i + 1;
		}
	}
}

void readFiles(char *topologyfile, char *messagefile) {
	for (int i = 0; i < 16; i ++) {
		for (int j = 0; j < 16; j ++) {
			topology[i][j] = 0;
		}
	}
	
	for (int i = 0; i < 16; i ++) {
		exist[i] = false;
		online[i] = false;
	}
	
	FILE *topf, *mesf;
	char *mode = "r";
	printf("start reading topology from %s\n", topologyfile);
	topf = fopen(topologyfile, mode);
	int from, to, dist;
	while (fscanf(topf, "%d %d %d",  &from, &to, &dist) != EOF) {
		topology[from-1][to-1] = dist;
		topology[to-1][from-1] = dist;
		if (!exist[from - 1]) {
			exist[from - 1] = true;
			numNode ++;
		}
		if (!exist[to - 1]) {
			exist[to - 1] = true;
			numNode ++;
		}
	}
	fclose(topf);
	printf("finish reading toplogy\n");
	printf("start reading message from %s\n", messagefile);
	mesf = fopen(messagefile, mode);
	char message[MAXMESSAGELENGTH];
	while (fscanf(mesf, "%d %d %100[^\n]",  &from, &to, message) != EOF) {
		(mes[numMessage]).from = from;
		(mes[numMessage]).to = to;
		strncpy ( (mes[numMessage]).message ,message,  sizeof(message) );
		mes[numMessage].path_counter = 0;
		numMessage ++;		
	}
	fclose(mesf);
	printf("finish reading messgae\n");

	return;
}

// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa)
{
	if (sa->sa_family == AF_INET) {
		return &(((struct sockaddr_in*)sa)->sin_addr);
	}

	return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int main(int argc, char *argv[])
{
	if (argc != 3) {
		perror("usage: manager topologyfile messagefile"); 
	}
	router_addr = (struct sockaddr_storage *) malloc(sizeof(struct sockaddr_storage) * 16);
	for (int i = 0; i < 16; i ++) {
	  online[i] = false;
	  exist[i] = false;
	}
	int sockfd;
	struct addrinfo hints, *servinfo, *p;
	int rv;
	int numbytes;
	struct sockaddr_storage their_addr;
	char buf[MAXBUFLEN];
	socklen_t addr_len;
	char s[INET6_ADDRSTRLEN];

	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_UNSPEC; // set to AF_INET to force IPv4
	hints.ai_socktype = SOCK_DGRAM;
	hints.ai_flags = AI_PASSIVE; // use my IP

	if ((rv = getaddrinfo(NULL, MYPORT, &hints, &servinfo)) != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
		return 1;
	}

	// loop through all the results and bind to the first we can
	for(p = servinfo; p != NULL; p = p->ai_next) {
		if ((sockfd = socket(p->ai_family, p->ai_socktype,
				p->ai_protocol)) == -1) {
			perror("manager: socket");
			continue;
		}

		if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
			close(sockfd);
			perror("manager: bind");
			continue;
		}

		break;
	}

	if (p == NULL) {
		fprintf(stderr, "manager: failed to bind socket\n");
		return 2;
	}

	freeaddrinfo(servinfo);

	
	
	readFiles(argv[1], argv[2]);
	
	//start to build topology
	addr_len = sizeof (router_addr[0]);
	int id;
	int terminator = 77;
	
	//char adjacent[16];
	//int pos = 0;
	for (int i = 0; i < numNode; i ++) {
	        id = i + 1;
	        if ((numbytes = recvfrom(sockfd, buf, MAXBUFLEN-1 , 0,
					 (struct sockaddr *) &(router_addr[id-1]), &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
		}
		
		//send node ID to node and set it to online
		online[id-1] = true;
		
		if (numbytes = sendto(sockfd, &id, sizeof(id), 0,
				      (struct sockaddr *) &(router_addr[id - 1]), sizeof(router_addr[id - 1])) == -1) {
			perror("sendto");
			exit(1);
		}
		    printf("set new node with ID %d\n", id);
		
		//send adjacent node information to nodes
		int adjacentnum = 0;
		for (int i = 0; i < 16; i ++) {
			if (exist[i] && topology[i][id-1] > 0 && i != id - 1) {
				adjacentnum ++;
			}
		}

	       	if (numbytes = sendto(sockfd, &numNode, sizeof(int), 0,
				      (struct sockaddr *)  &(router_addr[id-1]), sizeof(router_addr[id-1])) == -1) {
       		       	perror("sendto");
	 	       	exit(1);
		}

	       if (numbytes = sendto(sockfd, &adjacentnum, sizeof(int), 0,
				     (struct sockaddr *)  &(router_addr[id-1]), sizeof(router_addr[id-1])) == -1) {
       		       	perror("sendto");
	      	       	exit(1);
		}
		
		
		    printf("start sending node %d its neignbor information\n", id);
		struct adjacent_node n;
		
		for (int i = 0; i < 16; i ++) {
			if (exist[i] && topology[i][id-1] > 0 && i != id - 1) {
				
				//set adjacent node values
				n.id = i + 1;
				if(online[i]) {
				  memcpy(&(n.router_addr),&(router_addr[i]), sizeof(struct sockaddr_storage));
					n.online = true;
				}
				else {
				  //	n.router_addr = NULL;
					n.online = false;
				}
				n.cost = topology[i][id-1];
				
				//send adjacent node value information to nodes
				if (numbytes = sendto(sockfd, &n, sizeof(n), 0,
						      (struct sockaddr *)    &(router_addr[id-1]), sizeof(router_addr[id-1])) == -1) {
					perror("sendto");
					exit(1);
				}
			}
		}
			printf("finish sending neighbor information\n");
		
		       
		//if a new node is online, should send this update to all adjacent nodes that are already online
		
		n.id = id;
		n.online = true;
		//	n.router_addr = router_addr[id-1];
		 memcpy(&(n.router_addr),&(router_addr[id-1]), sizeof(struct sockaddr_storage));
		for (int i = 0; i < 16 ; i ++) {
			if(exist[i] && topology[i][id-1] > 0 && i != id-1 && online[i]) {
			  //n.cost = topology[i][id-1];
			  if (numbytes = sendto(sockfd, &id, sizeof(id), 0, (struct sockaddr *) &(router_addr[i]), sizeof(router_addr[i])) == -1) {
			    perror("sendto");
			    exit(1);
			  }
			  if (numbytes = sendto(sockfd, &(router_addr[id-1]), sizeof(router_addr[id-1]), 0, (struct sockaddr *) &(router_addr[i]), sizeof(router_addr[i])) == -1) {
			    perror("sendto");
			    exit(1);
			  }
			  
				/*
				if (numbytes = sendto(sockfd, &n, sizeof(n), 0,
						      (struct sockaddr *) &(router_addr[i]), sizeof(router_addr[i])) == -1) {
					perror("sendto");
					exit(1);
				}
				*/
			}
		}
	
		/*
		if ((numbytes = sendto(sockfd, &terminator, sizeof(terminator), 0,
			router_addr[id-1], sizeof(router_addr[id-1])) == -1) {
			perror("sendto");
			exit(1);
		}
		*/
		
		
	}
		  printf("All nodes are online now!\n");
		  
	//broadcast information that all nodes are online
	
	char temp[2];
	temp[0] = 's';
	temp[1] = '\0';
	for (int i = 0; i < 16; i ++) {
		if(exist[i] && online[i]) {
			if (numbytes = sendto(sockfd, temp, sizeof(temp), 0,
					      (struct sockaddr *)    &(router_addr[i]), sizeof(router_addr[i])) == -1) {
			perror("sendto");
			exit(1);
			}	
		}
	}
	
	//wait for all nodes to announce convergence
	int finished = 0;
	temp[0] = 'f';
	temp[1] = '\0';
	while (finished != numNode) {
	if ((numbytes = recvfrom(sockfd, buf, MAXBUFLEN-1 , 0,
			(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
		}
	
	if(!strcmp(temp, buf)) finished ++;
	
	}
	
	//send messgae information to corresponding nodes
	sendMessages(sockfd);
	
	update(sockfd);
	
	close(sockfd);

	return 0;
}
