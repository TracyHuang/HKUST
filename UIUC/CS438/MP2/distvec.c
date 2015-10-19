/*
** distvec.c --simulate distance vector routing protocol
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



#include <signal.h>

#define SERVERPORT "4950"	// the port users will be connecting to
#define MAXMESSAGELENGTH 100
#define MAXBUFLEN 100
#define MAXNUMMESSAGE 100

struct adjacent_node{
	int id;
	struct sockaddr* router_addr;
	int cost;
	bool online;
};

struct message{
	int from;
	int to;
	char message[MAXMESSAGELENGTH];
        int path[16];
  int path_counter;
};

struct top_edge{
	int from;
	int to;
	int cost;
};

struct forward_table{
	int next_hop;
  //struct sockaddr* router_addr;
	int cost;
	int dest;
};



//no global topology
bool exist[16];
int id;
int numNode;
struct adjacent_node adjacent_nodes[16];
int numAdjacentNode;
struct sockaddr* manager;
struct forward_table forward_table[16];
int timeout = 25;

int timeout_recvfrom (int sock, void  *buf, int length, struct sockaddr *connection, int* addr_len,  int timeoutinseconds)
{
    fd_set socks;
    struct timeval t;
    socklen_t socklen = *addr_len;
    FD_ZERO(&socks);
    FD_SET(sock, &socks);
    t.tv_sec = timeoutinseconds;
    if (select(sock + 1, &socks, NULL, NULL, &t) &&
        recvfrom(sock, buf, length, 0, connection, &socklen)!=-1)
        {
	  return 1; //receive data
        }
    else
      return 0;  //timeout
}

/*
int findSenderIndex(struct sockaddr* sock_addr) {
  for (int i = 0; i < numAdjacentNode; i ++) {
    if(*(adjacent_nodes[i].router_addr) == *(sock_addr)) {
      return i;
    }
  }
    return -1;   //error
}
*/

int id2index(int id) {
	for (int i = 0; i < numAdjacentNode; i ++) {
		if(adjacent_nodes[i].id == id) return i;
	}
	return -1; //error
}

int modifyForwardTable(struct forward_table entry, int index) {
	if(entry.cost + adjacent_nodes[index].cost < forward_table[entry.dest - 1].cost) {
		forward_table[entry.dest - 1].cost = entry.cost + adjacent_nodes[index].cost;
		forward_table[entry.dest - 1].next_hop = adjacent_nodes[index].id;
		//forward_table[entry.dest - 1].router_addr = adjacent_nodes[id - 1].router_addr;
		return 1;
	}
	return 0;
}

void buildForwardTable(int sockfd) {
	struct forward_table n;
	int numbytes;
	for (int i = 0; i < numAdjacentNode; i ++) {
		n.dest = adjacent_nodes[i].id;
		n.cost = adjacent_nodes[i].cost;
		//n.router_addr = adjacent_nodes[i].router_addr;
		n.next_hop = id;
		for (int j = 0; j < numAdjacentNode && j != i ; j ++) {
			if ((numbytes = sendto(sockfd, &n, sizeof(n) , 0,
				adjacent_nodes[j].router_addr, sizeof(adjacent_nodes[j].router_addr))) == -1) {
			perror("talker: sendto");
			exit(1);	
			}
		}
	}

	struct sockaddr * their_addr;
	int sender_id;
	int socklen = sizeof(*their_addr);
	while (timeout_recvfrom (sockfd, &n, sizeof(n), their_addr, &socklen, timeout)) {
	     // sender_index = findSenderIndex(their_adddr);
	     sender_id = n.next_hop;
	     
	     if(modifyForwardTable(n, id2index(sender_id))) {
			n.cost = n.cost + adjacent_nodes[id2index(sender_id)].cost;
			n.next_hop = id;
	       for (int i = 0; i < numAdjacentNode ; i ++ )  {
			if ((numbytes = sendto(sockfd, &n, sizeof(n) , 0,
				adjacent_nodes[i].router_addr, sizeof(*(adjacent_nodes[i].router_addr)))) == -1) {
				perror("talker: sendto");
				exit(1);
			}
		}
      }
    }
	
	//tell the manager that it is converged
    char temp[2];
    temp[0] = 'f';
    temp[1] = '\0';
    if (numbytes = sendto(sockfd, temp, 2 , 0,
		      manager, sizeof(*manager)) == -1) {
		perror("talker: sendto");
		exit(1);
	}

	return;
	
}

void sendMessage(int sockfd) {
	struct message mes;
  struct sockaddr * their_addr;
  struct sockaddr * next_node;
  int socklen = sizeof(*their_addr);
  while (timeout_recvfrom (sockfd, &mes, sizeof(mes), their_addr, &socklen, 40)) {
      mes.path[mes.path_counter] = id;
      mes.path_counter ++;
	  if(mes.to == id) {
		printf("packet received! The message is from node %d\n", mes.from);
		printf("%s\n", mes.message);
		printf("The message forwarding path is ");
		for (int i = 0; i < mes.path_counter; i ++) printf("%d ", mes.path[i]);
		continue;
	  }
      next_node = adjacent_nodes[id2index(forward_table[mes.to - 1].next_hop)].router_addr;
      int numbytes;
      if ((numbytes = sendto(sockfd, &mes, sizeof(mes) , 0,
			     next_node, sizeof(*next_node) )) == -1) {
		perror("talker: sendto");
		exit(1);
	}
    }

	char temp[2];
    temp[0] = 'f';
    temp[1] = '\0';
    int numbytes;
    if ((numbytes = sendto(sockfd, &temp, sizeof(temp) , 0,
				 manager, sizeof(*manager))) == -1) {
		perror("talker: sendto");
		exit(1);
	}
    
    return;

}


int main(int argc, char *argv[])
{
	int sockfd;
	struct addrinfo hints, *servinfo, *p;
	char buf[MAXBUFLEN];
	int rv;
	int numbytes;
	struct sockaddr_storage their_addr;
	socklen_t addr_len;
	
	/*
	if (argc != 3) {
		fprintf(stderr,"usage: talker hostname message\n");
		exit(1);
	}
	*/
	//signal(SIGALRM, ALARMhandler);
	
	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_DGRAM;

	if ((rv = getaddrinfo(argv[1], SERVERPORT, &hints, &servinfo)) != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
		return 1;
	}

	// loop through all the results and make a socket
	for(p = servinfo; p != NULL; p = p->ai_next) {
		if ((sockfd = socket(p->ai_family, p->ai_socktype,
				p->ai_protocol)) == -1) {
			perror("talker: socket");
			continue;
		}

		break;
	}

	if (p == NULL) {
		fprintf(stderr, "talker: failed to bind socket\n");
		return 2;
	}
	
	manager = p->ai_addr;
	char temp[2];
	temp[0] = 's';
	temp[1] = '\0';

	//notify the manager 
	if ((numbytes = sendto(sockfd, temp, strlen(temp), 0,
			 manager, sizeof(*manager))) == -1) {
		perror("talker: sendto");
		exit(1);
	}
	
	//receive manager assigned ID
	addr_len = sizeof (their_addr);
	if ((numbytes = recvfrom(sockfd, &id, sizeof(id), 0,
			(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
		}

	//receive number of adjacent node and their information in struct adjacent_node format
	
	if ((numbytes = recvfrom(sockfd, &numNode, sizeof(int), 0,
			(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
		}
	
	if ((numbytes = recvfrom(sockfd, &numAdjacentNode, sizeof(int), 0,
			(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
		}

	for (int i = 0; i < numNode; i ++) {
	  exist[i] = true;
	}
	
	//get all neignbor information from the manager
	int counter = 0;
	int offline = 0;
	struct adjacent_node n;
	struct forward_table m;
	while(counter < numAdjacentNode) {
	  if ((numbytes = recvfrom(sockfd, &n, sizeof(n), 0,
			(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
		}
	  adjacent_nodes[counter] = n;
	  m.next_hop = n.id;
	  //m.router_addr = n.router_addr;
	  m.cost = n.cost;
	  m.dest = n.id;
	  forward_table[n.id - 1] = m; 
	  counter ++;
	  if(!n.online) offline ++;
	}
	
	//wait for all other neighbors to be online
	while (offline != 0) {
		if ((numbytes = recvfrom(sockfd, &n, sizeof(n), 0,
			(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
		}
		for (int i = 0; i < numAdjacentNode; i ++) {
			if(adjacent_nodes[i].id == n.id) {
				adjacent_nodes[i] = n;
				break;
			}
		}
		
	offline --;
	}
	
	//set entry of itself
	forward_table[id - 1].next_hop = id;
	forward_table[id - 1].cost = 0;
	forward_table[id - 1].dest = id;
	
	//wait for the manager to notify that all nodes are online
	while (temp[0] != 's') {
	  if ((numbytes = recvfrom(sockfd, temp, MAXBUFLEN - 1 , 0,
			(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
	  }
	}

	buildForwardTable(sockfd);
	sendMessage(sockfd);
	
	freeaddrinfo(servinfo);

	//printf("talker: sent %d bytes to %s\n", numbytes, argv[1]);
	close(sockfd);

	return 0;
}
