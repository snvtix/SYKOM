#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#define MAX_BUFFER 1024

#define SYSFS_FILE_IN       "/sys/kernel/sykt/dsslna"
#define SYSFS_FILE_CTRL     "/sys/kernel/sykt/dtslna"
#define SYSFS_FILE_STATE    "/sys/kernel/sykt/dcslna"
#define SYSFS_FILE_RESULT   "/sys/kernel/sykt/drslna"

unsigned int read_from_file(char *filePath) {
    char buffer[MAX_BUFFER];
    int file = open(filePath, O_RDONLY);
    if (file < 0) {
        printf("Open %s - error number %d\n", filePath, errno);
        exit(5);
    }
    ssize_t n = read(file, buffer, MAX_BUFFER);
    close(file);
    if (n < 0) {
        printf("Read from %s - error number %d\n", filePath, errno);
        exit(5);
    }
    return strtoul(buffer, NULL, 16);
}

int write_to_file(char *filePath, unsigned int input) {
    char buffer[MAX_BUFFER];
    int ret;
    int size = snprintf(buffer, MAX_BUFFER, "%x", input);
    if (size < 0 || size >= MAX_BUFFER) {
        printf("Input value %x exceeds buffer size\n", input);
        exit(6);
    }
    FILE *file = fopen(filePath, "w");
    if (file == NULL) {
        printf("Open %s - error number %d\n", filePath, errno);
        exit(6);
    }
    ssize_t n = fwrite(buffer, sizeof(char), size, file);
    if (n != size) {
        printf("Write to %s - error number %d\n", filePath, errno);
        ret = -1;
    } else {
        ret = 0;
    }
    fclose(file);
    return ret;
}

void write_in(int in){
    printf("Writing 0x%x input value\n", in);
    if (write_to_file(SYSFS_FILE_IN, in) != 0){
        printf("Failed to write input value\n");
    }
}

void write_ctrl(int ctrl){
    if ((ctrl >> 8) == 0x0){
        printf("Writing command %x- memory cleaning\n", (ctrl >> 8));
    } 
    else if ((ctrl >> 8) == 0x1){
        printf("Writing command %x - back to position 0 in memory\n", (ctrl >> 8));
    } 
    else if ((ctrl >> 8) == 0x2){
        printf("Writing command %x - start counting\n", (ctrl >> 8));
    }

    if (write_to_file(SYSFS_FILE_CTRL, ctrl) != 0){
        printf("Failed to write command\n");
    }
}

void read_state(){
    unsigned int state;
    state = read_from_file(SYSFS_FILE_STATE);
    if ((state >> 10) == 0x0){
        printf("Current state %x - waiting for input\n", state >> 10);
    } 
    else if ((state >> 10) == 0x1){
        printf("Current state %x - ready for counting\n", state >> 10);
    } 
    else if ((state >> 10) == 0x2){
        printf("Current state %x - counting\n", state >> 10);
    }
    else if ((state >> 10) == 0x3){
        printf("Current state %x - counting finished\n", state >> 10);
    } 
}

void read_result(){
    unsigned int result;
    unsigned int state;
    do{
        state = read_from_file(SYSFS_FILE_STATE);
    } while ((state >> 10) != 0x3);
    result = read_from_file(SYSFS_FILE_RESULT);
    printf("Result: 0x%x\n", result);
}


int main(void) {
    printf("CRC16DECTR test 1\n");

    read_state();
    write_in(0xAA);
    read_state();
    write_ctrl(0x2 << 8);
    read_state();
    read_result();
    read_state();

    printf("CRC16DECTR test 2\n");

    read_state();
    write_ctrl(0x1 << 8);
    read_state();
    write_in(0x55);
    read_state();
    write_ctrl(0x2 << 8);
    read_state();
    read_result();
    read_state();

    printf("CRC16DECTR test 3\n");
    read_state();
    write_in(0xF);
    read_state();
    write_ctrl(0x2 << 8);
    read_state();
    read_result();
    read_state();

    printf("CRC16DECTR test 4\n");
    write_in(0xAA);
    write_in(0xBC);
    write_in(0x8);
    write_in(0xDD);
    write_ctrl(0x2 << 8);
    read_result();

    printf("Czyszczenie pamieci\n");
    write_ctrl(0x0 << 8);
    read_state();

    return 0;
}

