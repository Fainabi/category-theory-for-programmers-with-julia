// Cxx.jl is still under fixing, here use C codes
#include <stdbool.h>
#include <stdio.h>

bool f_bool() {
    puts("Hello!\n");
    return true;
}

int f_int(int x) {
    static int y = 0;
    y += x;
    return y;
}
