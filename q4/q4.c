#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

typedef int (*fptr)(int, int);

int main()
{
    char line[256];

    while(fgets(line, sizeof(line), stdin))
    {
        char op[6];
        int x,y;

        if (sscanf(line, "%5s %d %d", op, &x, &y) != 3) continue;
        

        char lib[20];
        snprintf(lib,sizeof(lib),"./lib%s.so",op);

        void* handle=dlopen(lib, RTLD_LAZY);

        if(!handle) continue;

        fptr operation=dlsym(handle,op);

        if(!operation) 
        {
            dlclose(handle);
            continue;
        }
        int result=operation(x,y);
        printf("%d\n",result);

        dlclose(handle);
    }

    return 0;
}