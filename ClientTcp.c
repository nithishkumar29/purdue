/* Client code to demonstarte socket programming */
#include<stdio.h>
#include<netinet/in.h> 
#include <string.h>
#define SERVERPORT 1070
int main(int argc,char **argv)
{
    int sockfd,n;
    char sendline[2000];
    char recvline[2000];
    struct sockaddr_in servaddr;
 		/* Sep 1 - Socket creation */
    sockfd=socket(AF_INET,SOCK_STREAM,0);
    bzero(&servaddr,sizeof servaddr);
    servaddr.sin_family=AF_INET;
    servaddr.sin_port=htons(SERVERPORT);
    inet_pton(AF_INET,"127.0.0.1",&(servaddr.sin_addr));
 		/* Step 2 - Connect to server */
    if(-1 != connect(sockfd,(struct sockaddr *)&servaddr, sizeof(servaddr)))
 		{
			printf("[Client] Connected to server!\n");
		  while(1)
		  {
			    bzero( sendline, sizeof(sendline));
			    bzero( recvline, sizeof(recvline));
		      printf("[Client] Enter message (x to stop): ");
		      scanf("%s" , sendline);
					if(0 == strcmp(sendline,"x")) break;
		      /* Step 3 - Send data to server */
		      if( send(sockfd , sendline , strlen(sendline) , 0) < 0)
		      {
		          puts("[Client] Send failed\n");
		          return 1;
		      }		       
		      /* Step 4 - Receive data from Server */
		      if( recv(sockfd , recvline , sizeof(recvline) , 0) < 0)
		      {
		          puts("[Client] recv failed\n");
		          break;
		      }		       
		      puts("[Client] Server reply :");
		      puts(recvline);
		  }
			/* Step 5 - Close socket */
			close(sockfd);
		}
		else
		{	
			printf("[Client] Connection failed!\n");
		}
}
 
