#include <menu.h>
#include <ncurses.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Technically NI_MAXHOST is 1025 (see <netdb.h>), so the maximum
// buffer size should be approx. 1025+3+19. But nobody's _THAT_ crazy.
#define BUFFER_SIZE 32
#define MAX_LINES 10 /* arbitrary number */

int get_ip_choices(char **argv, char lines[MAX_LINES][BUFFER_SIZE],
                   unsigned int *total_lines);
int main_loop(char lines[MAX_LINES][BUFFER_SIZE], unsigned int total_lines);
int create_sed(char **argv, char *line);

void handle_sigint(int sig) {
  endwin(); // Restore terminal settings
  printf("Caught signal %d. Exiting gracefully...", sig);
  exit(0); // Exit the program
}

int main(int argc, char **argv) {
  signal(SIGINT, handle_sigint);

  if (argc != 1) {
    fprintf(stderr, "Only provide the executable path.\n");
    return 1;
  }

  // Get IP choices -- data for ncurses options
  char lines[MAX_LINES][BUFFER_SIZE];
  unsigned int total_lines = 0;
  if (get_ip_choices(argv, lines, &total_lines) != 0) {
    fprintf(stderr, "Failed to get IP choices.\n");
    return 1;
  }

  // Run ncurses
  int line_index = main_loop(lines, total_lines);

  // Create actual sed script from first word of selected line
  create_sed(argv, lines[line_index]);

  return 0;
}

int get_ip_choices(char **argv, char lines[MAX_LINES][BUFFER_SIZE],
                   unsigned int *total_lines) {
  // Get real path of src/ip binary
  char *path = realpath(argv[0], NULL);
  if (path == NULL) {
    perror("Failed to get real path");
    return 1;
  }

  for (int i = strlen(path) - 1, slashes_found = 0; i >= 0; i--) {
    if (path[i] == '/') {
      slashes_found++;
      if (slashes_found == 2) {
        strcpy(&path[i], "/ip");
        break;
      }
    }
  }

  // Read IP choices from binary stdout
  FILE *pipe = popen(path, "r");
  if (pipe == NULL) {
    perror("Failed to open pipe");
    free(path);
    return 1;
  }

  while (*total_lines < MAX_LINES &&
         fgets(lines[*total_lines], BUFFER_SIZE, pipe) != NULL) {
    lines[*total_lines][strcspn(lines[*total_lines], "\n")] =
        0; /* Remove newline */
    (*total_lines)++;
  }

  pclose(pipe);
  free(path); // Free the path after use
  return 0;
}

int main_loop(char lines[MAX_LINES][BUFFER_SIZE], unsigned int total_lines) {
  int ch, highlight = 0;

  initscr();
  noecho();
  curs_set(0);
  keypad(stdscr, TRUE);
  clear();

  addstr("CONFIGURATION\n");
  addstr("=============\n");
  addstr("Select the IPv4 that you want to see in your shell.\n");
  while (1) {
    refresh();
    for (int i = 0; i < total_lines; i++) {
      if (i == highlight) {
        attron(A_REVERSE);
        mvaddstr(i + 3, 2, lines[i]);
        attroff(A_REVERSE);
      } else {
        mvaddstr(i + 3, 2, lines[i]);
      }
      addstr("\n");
    }
    ch = getch();
    if (ch == KEY_UP && highlight > 0) {
      highlight--;
    } else if (ch == KEY_DOWN && highlight < total_lines - 1) {
      highlight++;
    } else if (ch == '\n') {
      break;
    }
  }
  endwin();

  return highlight;
}

int create_sed(char **argv, char *line) {
  // Build real path of src/config/wireless.sed
  char *path = realpath(argv[0], NULL);
  if (path == NULL) {
    perror("Failed to get real path");
    return 1;
  }

  for (int i = strlen(path) - 1, slashes_found = 0; i >= 0; i--) {
    if (path[i] == '/') {
      slashes_found++;
      if (slashes_found == 1) {
        path[i] = '\0';
        strcat(path, "/wireless.sed");
        break;
      }
    }
  }

  // Extract actual WiFi interface
  char *interface = strtok(line, " ");
  if (interface == NULL) {
    perror("Failed to get interface");
    free(path);
    return 1;
  }

  // Create sed script
  FILE *file = fopen(path, "w");
  if (file == NULL) {
    perror("Failed to open file");
    free(path);
    return 1;
  }

  fprintf(file, "# Patches for netmask.zsh-theme\n");
  fprintf(file, "s:ip wl:ip %s:g\n", interface);

  fclose(file);
  free(path);
  return 0;
}