// The following code uses the C stdlib to get the
// IP address on an arbitrary Linux system.
// It is based on `man 3 getifaddrs § Program source`

#define _GNU_SOURCE /* To get defns of NI_MAXSERV and NI_MAXHOST */
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <linux/if_link.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

// #ifndef WLAN_TARGET
// #define WLAN_TARGET "wlp2s0"
// #endif

// #ifndef VPN_TARGET
// #define VPN_TARGET "tun0"
// #endif

int main(int argc, char *argv[]) {
  struct ifaddrs *ifaddr;
  int family, s;
  char host[NI_MAXHOST];
  uint8_t netmask = 0;
  uint32_t netmask_temp;

  if (getifaddrs(&ifaddr) == -1) {
    perror("getifaddrs");
    exit(EXIT_FAILURE);
  }

  /* Walk through linked list, maintaining head pointer so we
     can free list later. */

  for (struct ifaddrs *ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next) {
    if (ifa->ifa_addr == NULL)
      continue;

    // if (strncmp(ifa->ifa_name, WLAN_TARGET, strlen(WLAN_TARGET)) != 0 &&
    // strncmp(ifa->ifa_name, VPN_TARGET, strlen(VPN_TARGET)) != 0)
    //   continue;

    family = ifa->ifa_addr->sa_family;

    /* Pay attention to IPv4 only since AF_PACKET cannot be measured within
     * rootless Termux and AF_INET6 denotes IPv6 */
    if (family != AF_INET)
      continue;

    s = getnameinfo(ifa->ifa_addr, sizeof(struct sockaddr_in), host, NI_MAXHOST,
                    NULL, 0, NI_NUMERICHOST);
    if (s != 0) {
      printf("getnameinfo() failed: %s\n", gai_strerror(s));
      exit(EXIT_FAILURE);
    }

    /*if (family == AF_INET6) {
      // Hack to remove the %WLAN_TARGET thing from the end of an IPv6 address
      char *token = strtok(host, "%%");
      printf("%-8s: %s\n", ifa->ifa_name, token);
    } else {
    */

    /* Netmasks are 32-bit (four octals), but are often represented as
     * the number of contiguous 1 bits. */
    netmask_temp = ((struct sockaddr_in *)(ifa->ifa_netmask))->sin_addr.s_addr;
    while (netmask_temp) {
      netmask += netmask_temp & 1;
      netmask_temp >>= 1;
    }

    if (argc < 2) {
      printf("%-8s: %s/%hu\n", ifa->ifa_name, host, (uint16_t)netmask);
    } else {
      /* compare interface name to args */
      if (strncmp(argv[1], ifa->ifa_name, strlen(argv[1])) == 0) {
        printf("%s/%hu\n", host, (uint16_t)netmask);
        break;
      }
    }
  }

  freeifaddrs(ifaddr);
  exit(EXIT_SUCCESS);
}
