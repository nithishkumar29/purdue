/* Server code to demonstarte socket programming */
#include<stdio.h>
#include<netinet/in.h> 
#include <string.h>
#define MYPORT 1070

/* case conversion */
void uppercase(char *sPtr);

int main()
{
    char str[2000]={0};
    int listen_fd, comm_fd, read_size=0;
    struct sockaddr_in servaddr;

 		/* Step 1 - Server Socket creation */
    listen_fd = socket(AF_INET, SOCK_STREAM, 0);
    bzero( &servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = htons(INADDR_ANY);
    servaddr.sin_port = htons(MYPORT);
 		/* Step 2 - Assign Port number & IP address */
    bind(listen_fd, (struct sockaddr *) &servaddr, sizeof(servaddr));
 		/* Step 3 - Listen for incoming Connections */
    listen(listen_fd, 10);	
 		/* Step 4 - Accept the client connection */
		printf("[Server] Waiting for Client to connect\n");
    comm_fd = accept(listen_fd, (struct sockaddr*) NULL, NULL);
 		printf("[Server] Client connected!, waiting for data...\n");
    /* Step 5 - Receive data from client */
    while( (read_size = recv(comm_fd , str , sizeof(str) , 0)) > 0 )
    {				
				printf("[Server] Data from Client - %s\n",str);
				uppercase(str);
        /* Step 6 - Send processed data to client */
        write(comm_fd , str , strlen(str)+1);
				bzero( str, sizeof(str));
    }
    if(read_size == 0)
    {
        puts("[Server] Client disconnected\n");
        fflush(stdout);
    }
    else if(read_size == -1)
    {
        perror("[Server] recv failed\n");
    }
		/* Step 7 - Close sockets */
		close(comm_fd);
		close(listen_fd);
}
/* Dummy data processing */
void uppercase(char *sPtr) 
{  
        while(*sPtr != '\0') {
             *sPtr++ = toupper(*sPtr);
        }
}

