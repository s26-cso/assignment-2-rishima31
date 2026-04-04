.section .rodata
fmt:
    .asciz "%d "

.global main

main:
    addi sp,sp,-56
    sd ra,48(sp)
    sd a1,40(sp)                # save base address of argarr

    addi a0,a0,-1               # n = a0 - 1 (a0 counts the string ./a out as well)
    sd a0,32(sp)                # save number of elements

    li t0,4
    mul a0,a0,t0                # space for integers required
    call malloc
    sd a0,24(sp)                # save base address of arr

    ld a0,32(sp)                # a0 = n
    mul a0,a0,t0                # a0 = n*4
    call malloc
    sd a0,16(sp)                # save base address of result arr

    ld a0,32(sp)                # a0 = n
    mul a0,a0,t0                # a0 = n*4
    call malloc
    sd a0,8(sp)                 # save base address of stack arr 

    li t0,1                     # t0 = 1 (i)
    sd t0,0(sp)                 # save i

store_loop:
    ld t0,0(sp)                 # t0 = i
    ld s1,32(sp)
    bgt t0,s1,main_loop_helper  # if i > n go to main_loop

    li t1,8
    mul t1,t0,t1                # t1 = i*8 (pointers = 8 bytes)
    ld t4,40(sp)                # t4 = &arg
    add t5,t4,t1                # t5 = &arg[i]
    ld t2,0(t5)                 # t2 = arg[i]

    mv a0,t2                    # a0 = arg[i]
    call atoi                   # converts string to int

    ld t2,24(sp)                # t2 = base address of arr
    addi t3,t0,-1               # t3 = i - 1

    slli t6, t3, 2              # t6 = (i-1) * 4
    add t2,t2,t6                # t2 = &arr[i-1]

    sw a0,0(t2)                 # arr[i-1] = int (arg[i])

    addi t0,t0,1                # i++
    sd t0,0(sp)                 # save i
    j store_loop

main_loop_helper:
    ld t0,32(sp)                # t0 = n
    addi t0,t0,-1               # i = n-1
    sd t0,0(sp)                 # save i = n - 1


    li s0,-1                    # s0 = top = -1

    j main_loop

main_loop:
    ld t0,0(sp)                 # t0 = i

    blt t0,x0,end_helper        # if i < 0, end

    j while_loop

while_loop:

    ld t0,0(sp)                 # t0 = i

    blt s0,x0,end_while         # if top < 0, go to end_while
    
    slli t1, s0, 2              # t1 = top*4
    ld t2,8(sp)                 # t2 = &stack
    add t1,t2,t1                # t1 = &stack[top]
    lw t3,0(t1)                 # t3 = stack[top]

    slli t4,t3,2                # t4 = stack[top]*4
    ld t5,24(sp)                # t5 = &arr 
    add t4,t5,t4                # t4 = &arr[stack[top]]
    lw t6,0(t4)                 # t6 = arr[stack[top]]

    ld t4,24(sp)        # t4 = &arr
    slli t5,t0,2        # t5 = i*4
    add t4,t4,t5        # t4 = &arr[i]
    lw t5,0(t4)         # t5 = arr[i]

    ble t6,t5,pop               # if arr[stack[top]] <= arr[i], pop
    j end_while                 # else end while loop

end_while:
    blt s0,x0,empty_stack       # if top < 0, go to empty_stack

    ld t0,0(sp)                 # t0 = i

    slli t1, s0, 2              # t1 = top*4
    ld t2,8(sp)                 # t2 = &stack
    add t1,t2,t1                # t1 = &stack[top]
    lw t3,0(t1)                 # t3 = stack[top]
    
    slli t1,t0,2                # t1 = i*4
    ld t2,16(sp)                # t2 = &result
    add t1,t2,t1                # t1 = &result[i]
    sw t3,0(t1)                 # result[i] = stack[top]

    j push

empty_stack: 
    ld t0,0(sp)                 # t0 = i

    slli t1,t0,2                # t1 = i*4
    ld t2,16(sp)                # t2 = &result
    add t1,t2,t1                # t1 = &result[i]

    li t3,-1
    sw t3,0(t1)                 # result[i] = -1

    j push

pop:
    addi s0,s0,-1               # top--
    j while_loop

push:
    ld t0,0(sp)                 # t0 = i

    addi s0,s0,1                # top++

    slli t1, s0, 2              # t1 = top*4
    ld t2,8(sp)                 # t2 = &stack
    add t1,t2,t1                # t1 = &stack[top]
    sw t0,0(t1)                 # stack[top] = i

    add t0,t0,-1                # i--
    sd t0,0(sp)                 # save i

    j main_loop

end_helper:
    li t0,0                     # i = 0
    sd t0,0(sp)                 # save i

    j end_loop

end_loop:
    ld t0,0(sp)                 # t0 = i
    ld t1,32(sp)                # t1 = n

    bge t0,t1,end               # if i >= n, end

    slli t2,t0,2                # t2 = i*4
    ld t3,16(sp)                # t3 = &result
    add t2,t3,t2                # t2 = &result[i]
    lw t3,0(t2)                 # t3 = result[i] 

    la a0,fmt
    mv a1,t3                    
    call printf

    addi t0,t0,1               # i++
    sd t0,0(sp)                # save i

    j end_loop

end:
    ld ra,48(sp)
    addi sp,sp,56
    ret
