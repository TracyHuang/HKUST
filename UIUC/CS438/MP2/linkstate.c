/*
** linkstate.c ---simulate link state routing protocol
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
	struct sockaddr_storage router_addr;
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

int topology[16][16];
bool exist[16];
int id;
int numNode;
struct adjacent_node* adjacent_nodes;
int numAdjacentNode;
struct sockaddr* manager;

int timeout = 30;
//int terminator = 77;

const int maxint = 999999;
struct sockaddr_storage* Dijkstra(int u) {
  //first build datastructure
  // n -- n nodes
  // v -- the source node
  // u -- the target point
  // dist[] -- the distance from the ith node to the source node
  // prev[] -- the previous node of the ith node
  // c[][] -- every two nodes' distance
  // all index starts at 1
  int n = numNode;
  int v = id;
  int** c = new int*[n+1];
  for (int i = 0; i < n + 1; i ++) {
    c[i] = new int[n+1];
  }

  for (int i = 1; i<= n; i ++) 
    for (int j = 1; j <= n; j++) 
      c[i][j] = maxint;

  for (int i = 0; i < n; i ++) { 
    for (int j = 0; j < n; j ++) {
      if (topology[i][j] != 0) {
	c[i+1][j+1] = topology[i][j];
	c[j+1][i+1] = topology[i][j];
      }
    }
  }

  int* dist = new int[n+1];
  int* prev = new int[n+1]; 

  bool s[17];
  for(int i = 1; i <= n; i ++) {
    dist[i] = c[v][i];
    s[i] = false;
    if(dist[i] == maxint)
      prev[i] = 0;
    else
      prev[i] = v;
  }
  
  dist[v] = 0;
  s[v] = true;
  for(int i=2; i<=n; ++i)
	{
		int tmp = maxint;
		int u = v;
		//find the j that has lowest dist[j]
		for(int j=1; j<=n; ++j)
			if((!s[j]) && dist[j]<tmp)
			{
				u = j;              // u stores temp minimum point
				tmp = dist[j];
			}
		s[u] = true;    
 
		// update dist
		for(int j=1; j<=n; ++j)
			if((!s[j]) && c[u][j]<maxint)
			{
				int newdist = dist[u] + c[u][j];
				if(newdist < dist[j])
				{
					dist[j] = newdist;
					prev[j] = u;
				}
			}
	}



  //start search path
  //u is the target node

  int que[17];
  int tot = 1;
  que[tot] = u;
  tot ++;
  int tmp = prev[u];
  while (tmp != v) {
    que[tot] = tmp;
    tot ++;
    tmp = prev[tmp];
  }
  
  int next_node = que[tot-1];
  for (int i = 0; i < numAdjacentNode; i ++) {
    if ( adjacent_nodes[i].id == next_node )
      return &((adjacent_nodes[i]).router_addr);
  }
}





int timeout_recvfrom (int sock, void  *buf, int length, struct sockaddr *connection, int* addr_len,  int timeoutinseconds)
{
  socklen_t socklen = *addr_len;
    fd_set socks;
    struct timeval t;
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

int recv_within_time(int fd, void *buf, size_t buf_n,struct sockaddr* addr,socklen_t *len,unsigned int sec)
  {
      struct timeval tv;
      fd_set readfds;
      int i=0;
      unsigned int n=0;
      
         FD_ZERO(&readfds);
         FD_SET(fd,&readfds);
         tv.tv_sec=sec;
	 // tv.tv_usec=usec;
         select(fd+1,&readfds,NULL,NULL,&tv);
         if(FD_ISSET(fd,&readfds))
         {
             if((n=recvfrom(fd,buf,buf_n,0,addr,len))>=0)
             {    
                 return n;
             }
         }
     
     return -1;
}

int modifyTopology(struct top_edge edge) {
  if (topology[edge.from-1][edge.to-1] != edge.cost) {
    topology[edge.from-1][edge.to-1] = edge.cost;
    topology[edge.to-1][edge.from-1] = edge.cost;
    return 1;   // topology graph is changed
  }
  return 0; // topology graph is not changed
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

void printTopology() {
  for (int i = 0; i < numNode; i ++) {
    for (int j = 0; j < numNode; j ++) {
      printf("%d ", topology[i][j]);
    }
    printf("\n");
  }
}


void buildTopology(int sockfd) {
  struct top_edge edge;
  int numbytes;
  edge.from = id;
  for (int i = 0; i < numAdjacentNode ; i ++) {
    edge.to = (adjacent_nodes[i]).id;
    edge.cost = (adjacent_nodes[i]).cost;
    for (int j = 0; j < numAdjacentNode  ; j ++) {
      if (j == i) continue;
      if ((numbytes = sendto(sockfd, &edge, sizeof(edge) , 0,
			(struct sockaddr *) &(adjacent_nodes[j].router_addr), sizeof(adjacent_nodes[j].router_addr))) == -1) {
		perror("talker: sendto");
		exit(1);
	}
      printf("%d, %d\n", numbytes, sizeof(edge));
    }
  }

  printf("finish floating adjacent nodes\n");
  struct sockaddr * their_addr;
  int sender_index;
  int counter = 0;
  socklen_t len = sizeof(*their_addr);
  while (recv_within_time (sockfd, &edge, sizeof(edge), their_addr, &len, 5)) {
    printf("from %d to %d with cost %d\n", edge.from, edge.to, edge.cost);
      if(modifyTopology(edge)) {
	printTopology();
	//sender_index = findSenderIndex(their_adddr);
	for (int i = 0; i < numAdjacentNode ; i ++ ) {
	  if (numbytes = sendto(sockfd, &edge, sizeof(edge) , 0,
			(struct sockaddr *)	 &(adjacent_nodes[i].router_addr), sizeof(adjacent_nodes[i].router_addr) ) == -1) {
		perror("talker: sendto");
		exit(1);
	}
	}
      }
      counter ++;
      if (counter >= 5) break;
  }

  printTopology();
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
  struct sockaddr_storage * next_node;
  int numbytes;
  socklen_t len = sizeof(*their_addr);
  while (recv_within_time (sockfd, &mes, sizeof(mes), their_addr, &len, 25)) {
      mes.path[mes.path_counter] = id;
      mes.path_counter ++;
      if(mes.to == id) {
	printf("Receive the message from %d", mes.from);
	printf("The message is ' %s '\n", mes.message);
	continue;
      }
      printf("receive the message from %d to %d\n", mes.from, mes.to);
      next_node = Dijkstra(mes.to);
      int numbytes;
      if ((numbytes = sendto(sockfd, &mes, sizeof(mes) , 0,
			     (struct sockaddr*)    next_node, sizeof(*next_node) )) == -1) {
		perror("talker: sendto");
		exit(1);
	}
    }
    
    char temp[2];
    temp[0] = 'f';
    temp[1] = '\0';
    if ((numbytes = sendto(sockfd, &temp, 2 , 0,
				 manager, sizeof(*manager))) == -1) {
		perror("talker: sendto");
		exit(1);
	}
    
    return;
}



int main(int argc, char *argv[])
{
	adjacent_nodes = (struct adjacent_node *) malloc( sizeof(struct adjacent_node) * 16);
	for (int i = 0; i < 16; i ++) {
	  exist[i] = false;
	}
	int sockfd;
	struct addrinfo hints, *servinfo, *p;
	char buf[MAXBUFLEN];
	int rv;
	int numbytes;
	struct sockaddr_storage their_addr;
	socklen_t addr_len;

	
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
	temp[0] = 'a';
	temp[1] = '\0';
	
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
	printf("Assigned ID: %d\n", id);
	
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
	while(counter < numAdjacentNode) {
	  if ((numbytes = recvfrom(sockfd, &n, sizeof(n), 0,
			(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
		}
	  adjacent_nodes[counter] = n;
	  topology[id-1][n.id-1] = n.cost;
	  topology[n.id-1][id-1] = n.cost;
	  counter ++;
	  if(!n.online) offline ++;
	}
	
	printf("Received all needed information from manager\n");
	printf("Still wait for %d neighbors to be online\n", offline);
	
	//wait for all other neighbors to be online
	while (offline != 0) {
	  int node_id;
		if ((numbytes = recvfrom(sockfd, &node_id, sizeof(node_id), 0,
			(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
		}
		int i;
		for (i = 0; i < numAdjacentNode; i ++) {
			if(adjacent_nodes[i].id == node_id) {
				
				//printf("New neignbor %d information recorded successfully!\n", n.id );
				break;
			}
		}
		if ((numbytes = recvfrom(sockfd, &(adjacent_nodes[i].router_addr), sizeof(adjacent_nodes[i].router_addr), 0,
					 (struct sockaddr *) &their_addr, &addr_len)) == -1) {
		  perror("recvfrom");
		  exit(1);
		}
	offline --;
	printf("New neignbor %d information recorded successfully!\n",node_id );
	printf("Still wait for %d neighbors to be online\n", offline);
	}

	//wait for the manager to notify that all nodes are online
	while (temp[0] != 's') {
	  if ((numbytes = recvfrom(sockfd, temp, MAXBUFLEN - 1 , 0,
			(struct sockaddr *)&their_addr, &addr_len)) == -1) {
			perror("recvfrom");
			exit(1);
	  }
	}

	buildTopology(sockfd);

	sendMessage(sockfd);

	//update();
	freeaddrinfo(servinfo);
	close(sockfd);

	return 0;
}
